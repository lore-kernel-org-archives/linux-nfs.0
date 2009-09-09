From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Use GFP_NOFS in nfs_direct_req_alloc
Date: Tue, 08 Sep 2009 23:49:53 -0400
Message-ID: <1252468193.5092.29.camel@heimdal.trondhjem.org>
References: <20090908220230.7590.69833.stgit@matisse.1015granger.net>
	 <1252449178.8099.64.camel@heimdal.trondhjem.org>
	 <931F30AB-DC64-4A02-A96C-FABF0DD4059A@oracle.com>
	 <1252451130.8099.81.camel@heimdal.trondhjem.org>
	 <91BC2823-945F-4E23-A3E1-3CE1456C05DC@oracle.com>
	 <1252460233.5092.12.camel@heimdal.trondhjem.org>
	 <CDD6BAFB-F9E3-4724-893E-94589560E8BF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64232 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbZIIDu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 23:50:28 -0400
In-Reply-To: <CDD6BAFB-F9E3-4724-893E-94589560E8BF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-08 at 22:16 -0400, Chuck Lever wrote:
> On Sep 8, 2009, at 9:37 PM, Trond Myklebust wrote:
> > On Tue, 2009-09-08 at 21:01 -0400, Chuck Lever wrote:
> >> That is precisely the case here, in fact.  The upper file system is
> >> attempting to reclaim memory in the same kernel where the NFS client
> >> is trying to allocate with GFP_KERNEL.
> >
> > That's the "upper file system"'s problem, not ours... Stacking
> > filesystems causes issues. Screwing over the existing users of the
> > underlying filesystem is not a fix for those issues...
> 
> How does this change "screw over" the existing users of NFS O_DIRECT?

If they are low on memory, and call read() or write() on an O_DIRECT
file, the kernel will fail to start the necessary memory reclaim. Given
that by far the most common users of NFS O_DIRECT these days tend to be
large databases with rather heavy memory requirements our code changes
should rather be moving in the opposite direction w.r.t. use of
GFP_NOFS.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
