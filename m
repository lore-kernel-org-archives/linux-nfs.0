Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63040 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab1ASBps convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 20:45:48 -0500
Subject: RE: 4.1 no-pnfs mount option?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Daniel.Muntz@emc.com
Cc: matt@linuxbox.com, rees@umich.edu, androsadamson@gmail.com,
        linux-nfs@vger.kernel.org, bhalevy@panasas.com
In-Reply-To: <DE966DA98A4ABE438D726BDF1699CF61043985B639@MX05A.corp.emc.com>
References: <DE966DA98A4ABE438D726BDF1699CF61043985B639@MX05A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 18 Jan 2011 20:44:45 -0500
Message-ID: <1295401485.2941.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-18 at 19:53 -0500, Daniel.Muntz@emc.com wrote: 
> 
> > -----Original Message-----
> > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com] 
> > Sent: Tuesday, January 18, 2011 11:15 AM
> > To: Matt W. Benjamin
> > Cc: Muntz, Daniel; rees@umich.edu; androsadamson@gmail.com; 
> > linux-nfs@vger.kernel.org; Benny Halevy
> > Subject: Re: 4.1 no-pnfs mount option?
> > 
> > On Tue, 2011-01-18 at 13:46 -0500, Matt W. Benjamin wrote: 
> > > Hi,
> > > 
> > > Isn't by mount a plausible way to select for pnfs 
> > independent of debugging?  Is it assured that a client 
> > administrator would never reasonably wish to do this?
> > 
> > "Why would an administrator never want to do this?" is not a helpful
> > question.
> > 
> > A more useful question is "what reason would you possibly have for
> > overriding the server's request that you do pNFS when your client has
> > pNFS support?" What makes pNFS so special that we must allow
> > administrators to do this on a per-mount basis?
> 
> By the same logic, why should a user be allowed to select which version of NFS they use for mounting when the server has a perfectly reasonable way of negotiating it?  Getting to choose v2 vs. v3 vs. v4 seems like much less of a distinction than choosing between pNFS and no pNFS.  Frankly, it never even occurred to me that there wouldn't be a mount option to make this choice.  Enabling/disabling the layout driver doesn't fit the existing model of choosing mount behavior, and is a big hammer--it's all or nothing.
> 
> Anyway, here's a use case: I'm working at an HPC/gas+oil/satellite data site.  We have an awesome pNFS server for our big data and I want to access my big data with pNFS.  We have another server for homedirs, some big data, and other stuff.  Some mounts are fine with pNFS, others are abysmal.  So, I want to mount some directories with pNFS, and some without pNFS, on the same client, independent of the server configuration.

mount -t nfs -overs=4,minorversion=0 foo:/ /bar

Done... Any more questions?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

