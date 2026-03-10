import nodemailer from "nodemailer";
import { render } from "@react-email/components";
import { InvitationEmail } from "./templates/InvitationEmail.js";
import { LimitExceededEmail } from "./templates/LimitExceededEmail.js";
import { WeeklyReportEmail } from "./templates/WeeklyReportEmail.js";
import type { OrganizationReport } from "../../services/weekyReports/weeklyReportTypes.js";

// SMTP Configuration from environment variables
const SMTP_HOST = process.env.SMTP_HOST || "smtp.gmail.com";
const SMTP_PORT = parseInt(process.env.SMTP_PORT || "587");
const SMTP_SECURE = process.env.SMTP_SECURE === "true"; // true for 465, false for other ports
const SMTP_USER = process.env.SMTP_USER || "";
const SMTP_PASS = process.env.SMTP_PASS || "";
const SMTP_FROM = process.env.SMTP_FROM || "IWD Analytics <hello@increasewebdesign.com>";

let transporter: nodemailer.Transporter | undefined;

// Initialize SMTP transporter if credentials are provided
if (SMTP_USER && SMTP_PASS) {
  transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port: SMTP_PORT,
    secure: SMTP_SECURE,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
    tls: {
      // Do not fail on invalid certs (for self-signed certificates)
      rejectUnauthorized: false,
    },
  });

  // Verify SMTP connection on startup
  transporter.verify((error, success) => {
    if (error) {
      console.error("❌ SMTP connection failed:", error);
    } else {
      console.log("✅ SMTP server is ready to send emails");
    }
  });
} else {
  console.warn("⚠️  SMTP credentials not configured. Email functionality disabled.");
}

export const sendEmail = async (email: string, subject: string, html: string) => {
  if (!transporter) {
    console.warn("⚠️  Email not sent - SMTP not configured");
    return;
  }

  try {
    const info = await transporter.sendMail({
      from: SMTP_FROM,
      to: email,
      subject,
      html,
    });

    console.log("✅ Email sent successfully:", info.messageId);
    return info;
  } catch (error) {
    console.error("❌ Error sending email:", error);
    throw error;
  }
};

export const sendInvitationEmail = async (
  email: string,
  invitedBy: string,
  organizationName: string,
  inviteLink: string
) => {
  const html = await render(
    InvitationEmail({
      email,
      invitedBy,
      organizationName,
      inviteLink,
    })
  );

  await sendEmail(email, "You're Invited to Join an Organization on IWD Analytics", html);
};

export const sendLimitExceededEmail = async (
  email: string,
  organizationName: string,
  eventCount: number,
  eventLimit: number
) => {
  const upgradeLink = process.env.BASE_URL + "/settings/organization/subscription";

  const html = await render(
    LimitExceededEmail({
      organizationName,
      eventCount,
      eventLimit,
      upgradeLink,
    })
  );

  await sendEmail(email, `Action Required: ${organizationName} has exceeded its monthly event limit`, html);
};

export const sendWeeklyReportEmail = async (
  email: string,
  userName: string,
  organizationReport: OrganizationReport
) => {
  const html = await render(
    WeeklyReportEmail({
      userName,
      organizationReport,
    })
  );

  const subject = `Weekly Analytics Report - ${organizationReport.sites[0].siteName}`;

  await sendEmail(email, subject, html);
};

export const sendWelcomeEmail = async (email: string, name?: string) => {
  if (!transporter) return;

  const greeting = name ? `Hi ${name}` : "Hi there";
  const text = `${greeting},

Welcome to IWD Analytics! Thanks for signing up.

I'm excited to have you on board. IWD Analytics is fully self-hosted and we're fully committed to making an analytics platform that only serves the interests of our users.

If you run into any issues or have any questions or suggestions, just reply to this email - I'd love to hear from you.

Cheers,
Bill`;

  try {
    await transporter.sendMail({
      from: SMTP_FROM,
      replyTo: "hello@increasewebdesign.com",
      to: email,
      subject: "Welcome to IWD Analytics!",
      text,
    });
  } catch (error) {
    console.error("Failed to send welcome email:", error);
  }
};

// OTP Email (for sign-in, email verification, password reset)
export const sendOtpEmail = async (email: string, otp: string, type: "sign-in" | "email-verification" | "forget-password") => {
  if (!transporter) return;

  const subjects = {
    "sign-in": "Your IWD Analytics Sign-In Code",
    "email-verification": "Verify Your Email Address",
    "forget-password": "Reset Your Password",
  };

  const text = `Your verification code is: ${otp}\n\nThis code will expire in 10 minutes.`;

  try {
    await transporter.sendMail({
      from: SMTP_FROM,
      to: email,
      subject: subjects[type],
      text,
      html: `<p>Your verification code is: <strong>${otp}</strong></p><p>This code will expire in 10 minutes.</p>`,
    });
  } catch (error) {
    console.error("Failed to send OTP email:", error);
  }
};

// Marketing audience management (no-op for self-hosted)
export const addContactToAudience = async (email: string, firstName?: string): Promise<void> => {
  // Self-hosted instances don't use marketing audiences
  return;
};

export const isContactUnsubscribed = async (email: string): Promise<boolean> => {
  // Self-hosted instances don't track unsubscribes
  return false;
};

export const unsubscribeContact = async (email: string): Promise<void> => {
  // Self-hosted instances don't use marketing audiences
  return;
};

// Scheduled emails (no-op for self-hosted)
export const scheduleOnboardingTipEmail = async (
  email: string,
  userName: string,
  tipContent: any,
  scheduledAt: string
): Promise<string | null> => {
  // Self-hosted instances don't support scheduled emails
  console.log("Scheduled emails not supported in self-hosted mode");
  return null;
};

export const cancelScheduledEmail = async (emailId: string): Promise<void> => {
  // Self-hosted instances don't support scheduled emails
  return;
};

// Reengagement emails
export const sendReengagementEmail = async (
  email: string,
  userName: string,
  content: any,
  siteId: number,
  domain: string
): Promise<void> => {
  if (!transporter) return;

  const text = `Hi ${userName},\n\nWe noticed you haven't been active lately on ${domain}. Here's what you might have missed...`;

  try {
    await transporter.sendMail({
      from: SMTP_FROM,
      to: email,
      subject: "We miss you at IWD Analytics",
      text,
    });
  } catch (error) {
    console.error("Failed to send reengagement email:", error);
  }
};
