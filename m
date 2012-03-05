Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:36073 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753577Ab2CEVmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 16:42:47 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 5 Mar 2012 16:42:46 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 550B538C803A
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 16:42:42 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25Lgfrt336038
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 16:42:41 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25LgdDO030054
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 16:42:39 -0500
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q25Lgaw2029857
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 16:42:36 -0500
Date: Mon, 5 Mar 2012 15:42:35 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: How does the client manage NFS3ERR_NOSPC ?
Message-ID: <20120305214235.GC21904@us.ibm.com>
References: <4F54F4F0.108@cea.fr>
 <1330981266.2509.18.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330981266.2509.18.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> On Mon, 2012-03-05 at 18:16 +0100, DENIEL Philippe wrote:
> > Hi List,
> > 
> > I ran a stupid test (using the kernel's knfsd) : I filled up completely 
> > a filesystem with a few big file. When it was 100% full (no free block 
> > at all), I ran a dd on it.
> > The dd said it could write 793 blocks of size 1mb  and failed on IO 
> > error. At the end, I could see an empty file in the NFS exported tree.
> > Question is :
> >     - why did I get EIO and not ENOSPC ?
> 
> Did the server actually return NFS3ERR_NOSPC, or did it return something
> else? If the server returns NFS3ERR_NOSPC, then I'd expect the client to
> translate that as ENOSPC.

AFAIR, the server returns ENOSPC but the Linux client has a bug under
certain cases that returns it as EIO. Filed a bug and Neil sent a patch
but I have not tested it yet.

I tried with various versions and they gave some differing results. I
think in one case fsync() got ENOSPC but close() got EIO (or the other
way around?)

Regards, Malahal.
PS: Easy way to reproduce the problem, just run the following:
dd if=/dev/zero of=./testfile conv=fdatasync

