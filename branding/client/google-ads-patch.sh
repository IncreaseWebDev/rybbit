#!/bin/sh
# Google Ads Dashboard Patch for IWD Analytics
# This runs BEFORE the Next.js build to add Google Ads tracking page

set -e

echo "📊 Adding Google Ads dashboard to source files..."

# Create Google Ads page directory
mkdir -p /app/client/src/app/\[site\]/google-ads/components
mkdir -p /app/client/src/app/\[site\]/\[privateKey\]/google-ads

# 1. Create main Google Ads page
echo "📄 Creating Google Ads page..."
cat > /app/client/src/app/\[site\]/google-ads/page.tsx << 'GOOGLEADSPAGE'
"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useGetEventNames } from "../../../api/analytics/events/useGetEventNames";
import { DisabledOverlay } from "../../../components/DisabledOverlay";
import { useSetPageTitle } from "../../../hooks/useSetPageTitle";
import { SubHeader } from "../components/SubHeader/SubHeader";
import { GoogleAdsOverview } from "./components/GoogleAdsOverview";
import { GoogleAdsConversions } from "./components/GoogleAdsConversions";
import { GoogleAdsCampaigns } from "./components/GoogleAdsCampaigns";

export default function GoogleAdsPage() {
  useSetPageTitle("IWD Analytics · Google Ads");

  const { data: eventNamesData, isLoading: isLoadingEventNames } = useGetEventNames();

  const googleAdsEvents = eventNamesData?.filter((event: any) => 
    ['phone_click', 'booking_click', 'contact_click', 'email_click', 'appointment_widget_open', 'form_submission', 'google_ads_conversion'].includes(event.eventName)
  ) || [];

  return (
    <DisabledOverlay message="Google Ads Analytics" featurePath="google-ads">
      <div className="p-2 md:p-4 max-w-[1300px] mx-auto space-y-3">
        <SubHeader 
          availableFilters={[
            "utm_source",
            "utm_medium",
            "utm_campaign",
            "utm_term",
            "utm_content",
            "channel",
            "country",
            "city",
            "device_type",
            "browser",
            "operating_system"
          ]} 
        />

        <GoogleAdsOverview />

        <Card>
          <CardHeader>
            <CardTitle>Google Ads Conversions</CardTitle>
          </CardHeader>
          <CardContent>
            <GoogleAdsConversions events={googleAdsEvents} isLoading={isLoadingEventNames} />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Campaign Performance</CardTitle>
          </CardHeader>
          <CardContent>
            <GoogleAdsCampaigns />
          </CardContent>
        </Card>
      </div>
    </DisabledOverlay>
  );
}
GOOGLEADSPAGE

# 2. Create GoogleAdsOverview component
echo "📄 Creating GoogleAdsOverview component..."
cat > /app/client/src/app/\[site\]/google-ads/components/GoogleAdsOverview.tsx << 'OVERVIEW'
"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TrendingUp, MousePointerClick, Phone, Calendar } from "lucide-react";

export function GoogleAdsOverview() {
  const metrics = {
    totalVisits: 0,
    totalConversions: 0,
    conversionRate: 0,
    topConversion: "N/A"
  };

  return (
    <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Google Ads Visits</CardTitle>
          <TrendingUp className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{metrics.totalVisits}</div>
          <p className="text-xs text-muted-foreground">
            From campaigns with gclid or utm_source=google
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Total Conversions</CardTitle>
          <MousePointerClick className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{metrics.totalConversions}</div>
          <p className="text-xs text-muted-foreground">
            All tracked conversion events
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Conversion Rate</CardTitle>
          <Calendar className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{metrics.conversionRate}%</div>
          <p className="text-xs text-muted-foreground">
            Conversions / Visits
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Top Conversion</CardTitle>
          <Phone className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{metrics.topConversion}</div>
          <p className="text-xs text-muted-foreground">
            Most common conversion type
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
OVERVIEW

# 3. Create GoogleAdsConversions component
echo "📄 Creating GoogleAdsConversions component..."
cat > /app/client/src/app/\[site\]/google-ads/components/GoogleAdsConversions.tsx << 'CONVERSIONS'
"use client";

import { Phone, Calendar, Mail, MessageSquare, FormInput, MousePointerClick } from "lucide-react";

interface Event {
  eventName: string;
  count: number;
}

interface GoogleAdsConversionsProps {
  events: Event[];
  isLoading: boolean;
}

const eventIcons: Record<string, React.ReactNode> = {
  phone_click: <Phone className="h-5 w-5" />,
  booking_click: <Calendar className="h-5 w-5" />,
  email_click: <Mail className="h-5 w-5" />,
  contact_click: <MessageSquare className="h-5 w-5" />,
  form_submission: <FormInput className="h-5 w-5" />,
  appointment_widget_open: <Calendar className="h-5 w-5" />,
  google_ads_conversion: <MousePointerClick className="h-5 w-5" />
};

const eventLabels: Record<string, string> = {
  phone_click: "Phone Calls",
  booking_click: "Booking Clicks",
  email_click: "Email Clicks",
  contact_click: "Contact Clicks",
  form_submission: "Form Submissions",
  appointment_widget_open: "Appointment Widget Opens",
  google_ads_conversion: "Google Ads Conversions"
};

export function GoogleAdsConversions({ events, isLoading }: GoogleAdsConversionsProps) {
  if (isLoading) {
    return (
      <div className="space-y-3">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <div key={i} className="flex items-center justify-between p-4 border rounded-lg animate-pulse">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 bg-gray-200 rounded-full"></div>
              <div className="h-4 w-32 bg-gray-200 rounded"></div>
            </div>
            <div className="h-6 w-16 bg-gray-200 rounded"></div>
          </div>
        ))}
      </div>
    );
  }

  if (events.length === 0) {
    return (
      <div className="text-center py-12 text-muted-foreground">
        <MousePointerClick className="h-12 w-12 mx-auto mb-4 opacity-50" />
        <p className="text-lg font-medium">No conversion events tracked yet</p>
        <p className="text-sm mt-2">
          Conversion events will appear here once visitors from Google Ads interact with your site
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {events.map((event) => (
        <div
          key={event.eventName}
          className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors"
        >
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary">
              {eventIcons[event.eventName] || <MousePointerClick className="h-5 w-5" />}
            </div>
            <div>
              <p className="font-medium">{eventLabels[event.eventName] || event.eventName}</p>
              <p className="text-sm text-muted-foreground">Tracked conversion event</p>
            </div>
          </div>
          <div className="text-right">
            <p className="text-2xl font-bold">{event.count}</p>
            <p className="text-xs text-muted-foreground">conversions</p>
          </div>
        </div>
      ))}
    </div>
  );
}
CONVERSIONS

# 4. Create GoogleAdsCampaigns component
echo "📄 Creating GoogleAdsCampaigns component..."
cat > /app/client/src/app/\[site\]/google-ads/components/GoogleAdsCampaigns.tsx << 'CAMPAIGNS'
"use client";

import { TrendingUp, Users, MousePointerClick } from "lucide-react";

export function GoogleAdsCampaigns() {
  const campaigns: any[] = [];

  if (campaigns.length === 0) {
    return (
      <div className="text-center py-12 text-muted-foreground">
        <TrendingUp className="h-12 w-12 mx-auto mb-4 opacity-50" />
        <p className="text-lg font-medium">No campaign data available</p>
        <p className="text-sm mt-2">
          Campaign performance data will appear here once you have traffic from Google Ads campaigns
        </p>
        <div className="mt-6 p-4 bg-muted/50 rounded-lg max-w-md mx-auto text-left">
          <p className="font-medium mb-2">To track campaigns:</p>
          <ul className="text-sm space-y-1 list-disc list-inside">
            <li>Ensure your Google Ads campaigns use UTM parameters</li>
            <li>Include <code className="bg-background px-1 py-0.5 rounded">utm_source=google</code></li>
            <li>Include <code className="bg-background px-1 py-0.5 rounded">utm_medium=cpc</code></li>
            <li>Include <code className="bg-background px-1 py-0.5 rounded">utm_campaign=your_campaign_name</code></li>
          </ul>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {campaigns.map((campaign: any, index: number) => (
        <div
          key={index}
          className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors"
        >
          <div className="flex-1">
            <p className="font-medium">{campaign.name}</p>
            <p className="text-sm text-muted-foreground">{campaign.source} • {campaign.medium}</p>
          </div>
          <div className="flex gap-6 text-right">
            <div>
              <div className="flex items-center gap-1 text-muted-foreground mb-1">
                <Users className="h-3 w-3" />
                <span className="text-xs">Visits</span>
              </div>
              <p className="text-lg font-bold">{campaign.visits}</p>
            </div>
            <div>
              <div className="flex items-center gap-1 text-muted-foreground mb-1">
                <MousePointerClick className="h-3 w-3" />
                <span className="text-xs">Conversions</span>
              </div>
              <p className="text-lg font-bold">{campaign.conversions}</p>
            </div>
            <div>
              <div className="flex items-center gap-1 text-muted-foreground mb-1">
                <TrendingUp className="h-3 w-3" />
                <span className="text-xs">Rate</span>
              </div>
              <p className="text-lg font-bold">{campaign.conversionRate}%</p>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
CAMPAIGNS

# 5. Create private key route
echo "📄 Creating private key route..."
cat > /app/client/src/app/\[site\]/\[privateKey\]/google-ads/page.tsx << 'PRIVATEROUTE'
// Re-export the Google Ads page for private link routes
export { default } from "../../google-ads/page";
PRIVATEROUTE

echo "✅ Google Ads dashboard patch applied!"
echo "   (Navigation is added via source file modification)"
