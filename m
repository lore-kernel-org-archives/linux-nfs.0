From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] How to get information about the NFS version client
	and	server have negotiated on the server side?
Date: Wed, 4 Nov 2009 13:25:28 -0500
Message-ID: <20091104182528.GA10911@fieldses.org>
References: <20091103204228.GA5870@vasily.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Vasily Tarasov <tarasov-q12XvdSUhMJ7tPAFqOLdPg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37426 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757727AbZKDS0K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2009 13:26:10 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1N5kYg-0002oX-5S
	for linux-nfs@vger.kernel.org; Thu, 05 Nov 2009 05:26:14 +1100
In-Reply-To: <20091103204228.GA5870-q12XvdSUhMJ7tPAFqOLdPg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 03, 2009 at 03:42:28PM -0500, Vasily Tarasov wrote:
> I have the following question. NFS client and server negotiate the version they
> are going to use at the mount time. How can I get the info about their decision
> on the server-side?

I don't know of an easy way to get that information.

We could add some sort of interface to get that information, but I'm not
sure what it would look like.  On the server side this may be a less
well-defined question than you think, thanks to the stateless nature of
the protocol, and to differences in the way clients are identified
across the different protocol versions (especially v4 and v4.1).

--b.

> 
> /proc/fs/nfs/exports gives me the list of currently active
> exports, though not per-client:
> 
> # cat /proc/fs/nfs/exports 
> # Version 1.1
> # Path Client(Flags) # IPs
> /export 172.16.179.0/22(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,fsid=0)
> 
> /var/lib/nfs/rmtab file gives me the list of currently mounted clients, but
> does not specify the version:
> 
> # cat /var/lib/nfs/rmtab 
> 172.16.179.131:/export:0x00000001
> 
> 
> nfsstat (and corresponding /proc entry) does not help to, because there might
> be multiple clients working with different protocol versions at the same time.
> And I want to know what protocol is used by a specific one, while nfsstat gives
> only aggregate statistics.
> 
> On the client I can easily conclude protocol version from the /proc/mounts entry.
> 
> My config: CentOS5, nfs-utils-1.0.9-40.el5, kernel-2.6.18-128.el5 
> 
> Any ideas? Thank you!
> 
> Vasily
> 
> ------------------------------------------------------------------------------
> Come build with us! The BlackBerry(R) Developer Conference in SF, CA
> is the only developer event you need to attend this year. Jumpstart your
> developing skills, take BlackBerry mobile applications to market and stay 
> ahead of the curve. Join us from November 9 - 12, 2009. Register now!
> http://p.sf.net/sfu/devconference
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

