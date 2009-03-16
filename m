From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: issues with project quota over nfs
Date: Mon, 16 Mar 2009 08:37:05 -0400
Message-ID: <1237207025.7229.11.camel@heimdal.trondhjem.org>
References: <AD300F292705ED4089373955E129C1780491E77D@RBSJX.ad.redback.com>
	 <20090315205516.GB26627@fieldses.org>  <49BDC189.10104@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51093 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760841AbZCPMhO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2009 08:37:14 -0400
In-Reply-To: <49BDC189.10104@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-03-16 at 14:03 +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> > On Fri, Mar 13, 2009 at 09:59:26AM -0700, Brian Wince wrote:
> >   
> >> All,
> >> We have a Quad-core server running gentoo 2.6.27-r7 that is used as an nfs server for a xfs partition.
> >> We are using project quota's on directories within this partition and exporting this.
> >> When a client tries to untar in the dir with project quotas set and reaches the quota limit the load on the NFS server goes up dramatically and stays like this for a few minutes after the tar has gone through trying to write all of it files and failing due to quota limit exceeded.
> >>  
> >> Is this a known issue and if so is there anything that can be done to resolve this.
> >>  
> >> We do not see this issue if on the locally mounted partition. This only happens over NFS.
> >>  
> >> Please let me know if you need more information or if this should be addressed on a different list.
> >>     
> >
> > It doesn't sounds familiar to me.  Might also be worth cc:'ing xfs
> > people.
> >
> >
> >   
> Oh dear.  Brian asked it there frst, and I redirected him here.  In the
> absence of network traces, it smelt to me like the old client problem
> where errors like ENOSPC or EDQUOT during writeback were only returned
> to the app on close() and not the next write(), thus causing clients
> which exceed  quota during long streaming writes pointlessly to send a
> lot of data to the server all of which is dropped on the server.
> 

The patch "NFS: Fall back to synchronous writes when a background write
errors..."
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=7b159fc18d417980f57aef64cab3417ee6af70f8
was merged prior to 2.6.27.

That helps catch the problem earlier on the client, but IIRC XFS had
(has?) some kind of advanced error recovery routines that exacerbated
the problem on the server side by taking forever to figure out that this
was an irrecoverable error.

Cheers
  Trond

