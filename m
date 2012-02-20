Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14994 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab2BTFgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Feb 2012 00:36:07 -0500
Message-ID: <1329716158.2703.46.camel@serendib>
Subject: Re: NFS Mount Option 'nofsc'
From: Harshula <harshula@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Derek McEachern <derekm@ti.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 20 Feb 2012 16:35:58 +1100
In-Reply-To: <1328892525.13180.102.camel@lade.trondhjem.org>
References: <4F31E1CA.8060105@ti.com>
	 <1328676860.2954.9.camel@lade.trondhjem.org>
	 <1328687026.8981.25.camel@serendib>
	 <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
	 <1328759776.8981.75.camel@serendib>
	 <1328760721.3234.86.camel@lade.trondhjem.org>
	 <1328766702.8981.106.camel@serendib>
	 <1328801489.13180.41.camel@lade.trondhjem.org>
	 <1328861244.8981.139.camel@serendib>
	 <1328892525.13180.102.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Fri, 2012-02-10 at 16:48 +0000, Myklebust, Trond wrote:
> On Fri, 2012-02-10 at 19:07 +1100, Harshula wrote:

> > Do you see forcedirectio as a sharp object that someone could stab
> > themselves with?
> 
> Yes. It does lead to some very subtle POSIX violations.

I'm trying out the alternatives. Your list of reasons were convincing. Thanks.

> > If the NFS client only does cached async reads of a slowly growing file
> > (tail), what's the problem? Is nfs_readpage_sync() gone forever, or
> > could it be revived?
> 
> It wouldn't help at all. The problem is the VM's handling of pages vs
> the NFS handling of file size.
> 
> The VM basically uses the file size in order to determine how much data
> a page contains. If that file size changed between the instance we
> finished the READ RPC call, and the instance the VM gets round to
> locking the page again, reading the data and then checking the file
> size, then the VM may end up copying data beyond the end of that
> retrieved by the RPC call.

nfs_readpage_sync() keeps doing rsize reads (or PAGE SIZE reads if rsize
> PAGE SIZE) till the entire PAGE has been filled or EOF is hit. Since
these are synchronous reads, the subsequent READ RPC call is not sent
until the previous READ RPC reply arrives. Hence, the READ RPC reply
contains the latest metadata about the file, from the NFS server, before
deciding whether or not to do more READ RPC calls. That is not the case
with the asynchronous READ RPC calls which are queued to be sent before
the replies are received. This results in not READing enough data from
the NFS server even when the READ RPC reply explicitly states that the
file has grown. This mismatch of data and file size is then presented to
the VM.

If you look at nfs_readpage_sync() code, it does not worry about
adjusting the number of bytes to read if it is past the *current* EOF.
Only the async code adjusts the number of bytes to read if it is past
the *current* EOF. Furthermore, testing showed that using -osync (while
nfs_readpage_sync() existed) avoided the NULLs being presented to
userspace.

cya,
#

