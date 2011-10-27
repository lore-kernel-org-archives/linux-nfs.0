Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:46340 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab1J0WSc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2011 18:18:32 -0400
Date: Thu, 27 Oct 2011 22:17:42 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS4 BAD_STATEID loop (kernel 3.0.4)
Message-ID: <20111027221742.GI32587@rd.bbc.co.uk>
References: <20111024104042.GD32587@rd.bbc.co.uk>
 <1319455367.8505.3.camel@lade.trondhjem.org>
 <20111024131734.GE32587@rd.bbc.co.uk>
 <1319463165.2734.1.camel@lade.trondhjem.org>
 <20111024145027.GF32587@rd.bbc.co.uk>
 <1319470302.2734.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319470302.2734.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> Do you have an example of the stateid argument's value? Does it change
> at all between separate WRITE attempts?

Further to all this, i've just had a similar fault on another machine,
producing a huge amounts of:

 [463795.630702] nfs4_reclaim_open_state: Lock reclaim failed!
 [463795.637446] nfs4_reclaim_open_state: Lock reclaim failed!
 [463795.643113] nfs4_reclaim_open_state: Lock reclaim failed!

A network capture is available:
  ftp://ftp.kw.bbc.co.uk/davidf/priv/uekahrae.pcap

$ echo 0 | sudo tee /proc/sys/sunrpc/rpc_debug
[468024.010036] -pid- flgs status -client- --rqstp- -timeout ---ops--
[468024.010051]  6289 0801      0 ffff8801f3e37e00   (null)        0 ffffffffa0229d40 nfsv4 WRITE a:call_start q:NFS client
[468024.010057]  6290 0801      0 ffff8801f3e37e00   (null)        0 ffffffffa0229d40 nfsv4 WRITE a:call_start q:NFS client

blocked task:

 [464304.799306] INFO: task rrdtool:28506 blocked for more than 120 seconds.
 [464304.799309] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
 [464304.799311] rrdtool         D 0000000000000001     0 28506   4189 0x00000000
 [464304.799315]  ffff880073bd5ca8 0000000000000082 ffff8804232c5408 0000000000012a40
 [464304.799318]  ffff880073bd5fd8 0000000000012a40 ffff880073bd4000 0000000000012a40
 [464304.799320]  0000000000012a40 0000000000012a40 ffff880073bd5fd8 0000000000012a40
 [464304.799322] Call Trace:
 [464304.799332]  [<ffffffff81110030>] ? __lock_page+0x70/0x70
 [464304.799335]  [<ffffffff8160007c>] io_schedule+0x8c/0xd0
 [464304.799337]  [<ffffffff8111003e>] sleep_on_page+0xe/0x20
 [464304.799339]  [<ffffffff816008ff>] __wait_on_bit+0x5f/0x90
 [464304.799341]  [<ffffffff81110203>] wait_on_page_bit+0x73/0x80
 [464304.799345]  [<ffffffff81085bf0>] ? autoremove_wake_function+0x40/0x40
 [464304.799347]  [<ffffffff8111c5e5>] ? pagevec_lookup_tag+0x25/0x40
 [464304.799349]  [<ffffffff81110436>] filemap_fdatawait_range+0xf6/0x1a0
 [464304.799363]  [<ffffffffa02037d0>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
 [464304.799365]  [<ffffffff8111bae1>] ? do_writepages+0x21/0x40
 [464304.799367]  [<ffffffff811116bb>] ? __filemap_fdatawrite_range+0x5b/0x60
 [464304.799368]  [<ffffffff81111730>] filemap_write_and_wait_range+0x70/0x80
 [464304.799371]  [<ffffffff8119cc6a>] vfs_fsync_range+0x5a/0x90
 [464304.799373]  [<ffffffff8119cd0c>] vfs_fsync+0x1c/0x20
 [464304.799377]  [<ffffffffa01f7c74>] nfs_file_flush+0x54/0x80 [nfs]
 [464304.799380]  [<ffffffff8116ee7f>] filp_close+0x3f/0x90
 [464304.799382]  [<ffffffff8116f8a7>] sys_close+0xb7/0x120
 [464304.799384]  [<ffffffff8160a702>] system_call_fastpath+0x16/0x1b

Regards,
..david
