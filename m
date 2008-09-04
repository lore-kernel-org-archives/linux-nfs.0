From: Olaf Kirch <okir@suse.de>
Subject: Re: RESTRICTED_STATD
Date: Thu, 4 Sep 2008 09:38:43 +0200
Message-ID: <200809040938.43800.okir@suse.de>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com> <EB1B1F05-65DA-4A18-80F6-13DE4FCB387C@oracle.com> <18623.31268.970805.5694@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Steve Dickson <steved@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:32875 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbYIDHiq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 03:38:46 -0400
In-Reply-To: <18623.31268.970805.5694-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 04 September 2008 08:03:16 Neil Brown wrote:
> If it was to only check one, it would probably to check ip_addr
> against dns_name.

Right. Comparing the mon_name and the the result of the DNS reverse
lookup is additional paranoia, and should be configurable. In some
environments, not all machines will have reverse DNS entries, or
if they do, the name will not necessarily match what they've set
as their hostname. You could argue that this is a broken configuration,
but it is certainly not that uncommon.

> The IP address of that the SM_NOTIFY came from is the most reliable
> thing we have to identify which host just rebooted.  We use that to
> find a 'dns_name' when we first MONitor a host, and use that name for
> the file stored in /var/lib/nfs/sm.  We then match the source of
> SM_NOTIFY against those file names.
> 
> So I think this part of the code really does need to be IPv6-aware.
> Certainly matchhostname does.

Yes.

> > > However we don't really want any user to be able to request a callback
> > > to any random service....
> > > I wonder if anyone uses for statd for anything but lockd, and how
> > > could we know?
> > 
> > I think the real question is whether we should continue to support  
> > this "off-label" use.  It adds complexity and security problems, and  
> > the code paths that support this aren't ever tested these days, I'm  
> > willing to bet.
> 
> How about we subtly break it, and then we nobody complains for 12
> months, remove it as it was broken anyway :-)
> 
> I'm think I'm happy with removing any support for non-lockd uses for
> statd.

Me too. The whole NSM thing was totally over-engineered from day one.

Olaf
-- 
 And mention in the Fitz incident that DCOP is no ego shooter!
                                --micha istinie, 2001
