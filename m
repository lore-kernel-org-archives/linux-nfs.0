Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:52269 "EHLO esri3.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754551Ab1ASPFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 10:05:01 -0500
Date: Wed, 19 Jan 2011 07:04:50 -0800
From: Ray Van Dolson <rvandolson@esri.com>
To: "Red Hat Enterprise Linux 6 (Santiago) discussion mailing-list"
	<rhelv6-list@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [rhelv6-list] NFSv4 automount - nss_getpwnam name
 'user@domain.com' does not map into domain 'localdomain'
Message-ID: <20110119150450.GA20013@esri.com>
References: <20110119002907.GA25400@esri.com>
 <OF2761AC3A.66844802-ON8625781D.004EE4C7-8625781D.004EE7C9@uscmail.uscourts.gov>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF2761AC3A.66844802-ON8625781D.004EE4C7-8625781D.004EE7C9@uscmail.uscourts.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 19, 2011 at 06:22:35AM -0800, Greg_Swift@aotx.uscourts.gov wrote:
> 
> 
> rhelv6-list-bounces@redhat.com wrote on 01/18/2011 06:29:07 PM:
> 
> > Am doing a kickstart installation of RHEL 6.0 vanilla (no errata
> > applied).
> >
> > After reboot, when using the automounter to access NFSv4 shares
> > (running on Fedora 13), we see the following in the logs on the RHEL6
> > client:
> >
> > Jan 18 15:56:16 rhel6test rpc.idmapd[1387]: nss_getpwnam: name
> > 'root@esri.com' does not map into domain 'localdomain'
> > Jan 18 15:56:16 rhel6test rpc.idmapd[1387]: nss_getpwnam: name
> > 'ray5147@esri.com' does not map into domain 'localdomain'
> >
> > As a result, directories are not mapped to the correct users but
> > instead to 'nobody'.
> >
> > This is odd, because per the idmap man pages, the default domain used
> > by rpc.idmapd should be the same as the system domain minus the
> > hostname.  This should be esri.com, and is when I type hostname.
> >
> > Thinking that perhaps rpc.idmapd was started before the network
> > subsystem, I restarted it.  Immediately everything worked fine.
> >
> > I rebooted the system assuming the problem would return, but it didn't.
> > Maybe there's a cache used by rpc.idmapd (nscd?)?  Is there something
> > else maybe I'm missing?
> >
> > Trying to determine if the "right" thing to do is to leave my
> > configuration as default or if I should be modifying /etc/idmapd.conf
> > to set a default domain.
> 
> shot in the dark... is your real hostname also mapped to
> localhost.localdomain in /etc/hosts?

Yes, it is... I'd stumbled across a similar suggestion, but kinda was
puzzled that things seemed to start working even without changing the
entry in /etc/hosts.

This is what made me think nscd or some caching was involved...

Ray
