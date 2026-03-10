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
