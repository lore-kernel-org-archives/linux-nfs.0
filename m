Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4.res.gtwy.uscourts.gov ([208.27.111.134]:16497 "EHLO
	smtp4.res.gtwy.uscourts.gov" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752669Ab1ASQBd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 11:01:33 -0500
In-Reply-To: <20110119150450.GA20013@esri.com>
References: <20110119002907.GA25400@esri.com>	<OF2761AC3A.66844802-ON8625781D.004EE4C7-8625781D.004EE7C9@uscmail.uscourts.gov> <20110119150450.GA20013@esri.com>
Subject: Re: [rhelv6-list] NFSv4 automount - nss_getpwnam name 'user@domain.com' does
 not map into domain 'localdomain'
To: "Red Hat Enterprise Linux 6 \(Santiago\) discussion mailing-list"
	<rhelv6-list@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Red Hat Enterprise Linux 6 (Santiago) discussion mailing-list"
	<rhelv6-list@redhat.com>,
        rhelv6-list-bounces@redhat.com
Message-ID: <OFAB65B798.3724E99D-ON8625781D.0056CEF8-8625781D.0057212F@uscmail.uscourts.gov>
From: Greg_Swift@aotx.uscourts.gov
Date: Wed, 19 Jan 2011 09:52:25 -0600
Content-type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



rhelv6-list-bounces@redhat.com wrote on 01/19/2011 09:04:50 AM:

> > > Am doing a kickstart installation of RHEL 6.0 vanilla (no errata
> > > applied).
> > >
> > > After reboot, when using the automounter to access NFSv4 shares
> > > (running on Fedora 13), we see the following in the logs on the RHEL6
> > > client:
> > >
> > > Jan 18 15:56:16 rhel6test rpc.idmapd[1387]: nss_getpwnam: name
> > > 'root@esri.com' does not map into domain 'localdomain'
> > > Jan 18 15:56:16 rhel6test rpc.idmapd[1387]: nss_getpwnam: name
> > > 'ray5147@esri.com' does not map into domain 'localdomain'
> > >
> > > As a result, directories are not mapped to the correct users but
> > > instead to 'nobody'.
> > >
> > > This is odd, because per the idmap man pages, the default domain used
> > > by rpc.idmapd should be the same as the system domain minus the
> > > hostname.  This should be esri.com, and is when I type hostname.
> > >
> > > Thinking that perhaps rpc.idmapd was started before the network
> > > subsystem, I restarted it.  Immediately everything worked fine.
> > >
> > > I rebooted the system assuming the problem would return, but it
didn't.
> > > Maybe there's a cache used by rpc.idmapd (nscd?)?  Is there something
> > > else maybe I'm missing?
> > >
> > > Trying to determine if the "right" thing to do is to leave my
> > > configuration as default or if I should be modifying /etc/idmapd.conf
> > > to set a default domain.
> >
> > shot in the dark... is your real hostname also mapped to
> > localhost.localdomain in /etc/hosts?
>
> Yes, it is... I'd stumbled across a similar suggestion, but kinda was
> puzzled that things seemed to start working even without changing the
> entry in /etc/hosts.
>
> This is what made me think nscd or some caching was involved...


well it makes sense to ask.  i think the hosts file is exactly the issue
though because if its starting before the network it is resolving based on
local /etc/hosts entry.  However maybe NFS (or underlying dns layer) is
smart enough to realize that if there is network access its better to do
the hostname lookup against the dns servers.?  So once you restarted it
after the network is available, it got the right domain and worked.

I personally recommend (normally, not just in this situation) that if your
hostname maps to a specific IP, you can still put that mapping
in /etc/hosts, but make sure that only localhost and localhost.domain are
mapping to 127.0.0.1.

-greg

