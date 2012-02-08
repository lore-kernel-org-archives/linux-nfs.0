Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:63241 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756282Ab2BHPk4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 10:40:56 -0500
Subject: Re: NFS Mount Option 'nofsc'
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1328687026.8981.25.camel@serendib>
Date: Wed, 8 Feb 2012 10:40:47 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Derek McEachern <derekm@ti.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
References: <4F31E1CA.8060105@ti.com> <1328676860.2954.9.camel@lade.trondhjem.org> <1328687026.8981.25.camel@serendib>
To: Harshula <harshula@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 8, 2012, at 2:43 AM, Harshula wrote:

> Hi Trond,
> 
> On Wed, 2012-02-08 at 04:55 +0000, Myklebust, Trond wrote:
> 
>> Applications that need to use uncached i/o are required to use the
>> O_DIRECT open() mode instead, since pretty much all of them need to be
>> rewritten to deal with the subtleties involved anyway.
> 
> Could you please expand on the subtleties involved that require an
> application to be rewritten if forcedirectio mount option was available?
> 
> A scenario where forcedirectio would be useful is when an application
> reads nearly a TB of data from local disks, processes that data and then
> dumps it to an NFS mount. All that happens while other processes are
> reading/writing to the local disks. The application does not have an
> O_DIRECT option nor is the source code available.
> 
> With paged I/O the problem we see is that the NFS client system reaches
> dirty_bytes/dirty_ratio threshold and then blocks/forces all the
> processes to flush dirty pages. This effectively 'locks' up the NFS
> client system while the NFS dirty pages are pushed slowly over the wire
> to the NFS server. Some of the processes that have nothing to do with
> writing to the NFS mount are badly impacted. A forcedirectio mount
> option would be very helpful in this scenario. Do you have any advice on
> alleviating such problems on the NFS client by only using existing
> tunables?

Using direct I/O would be a work-around.  The fundamental problem is the architecture of the VM system, and over time we have been making improvements there.

Instead of a mount option, you can fix your application to use direct I/O.  Or you can change it to provide the kernel with (better) hints about the disposition of the data it is generating (madvise and fadvise system calls).  (On Linux we assume you have source code and can make such changes.  I realize this is not true for proprietary applications).

You could try using the "sync" mount option to cause the NFS client to push writes to the server immediately rather than delaying them.  This would also slow down applications that aggressively dirties pages on the client.

Meanwhile, you can dial down the dirty_ratio and especially the dirty_background_ratio settings to trigger earlier writeback.  We've also found increasing min_free_bytes has positive effects.  The exact settings depend on how much memory your client has.  Experimenting yourself is pretty harmless, so I won't give exact settings here.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




