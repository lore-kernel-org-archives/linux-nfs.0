From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: A unresponsive file system can hang all I/O in the system on
	linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 15:16:11 -0400
Message-ID: <1191006971.6702.25.camel@heimdal.trondhjem.org>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	 <20070927235034.ae7bd73d.akpm@linux-foundation.org>
	 <1190998853.6702.17.camel@heimdal.trondhjem.org>
	 <20070928114930.2c201324.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qxro6/a9LI9DLDRDrQ2v"
Cc: Chakri n <chakriin5@gmail.com>,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755186AbXI1TQi@vger.kernel.org>
In-Reply-To: <20070928114930.2c201324.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--=-qxro6/a9LI9DLDRDrQ2v
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2007-09-28 at 11:49 -0700, Andrew Morton wrote:
> On Fri, 28 Sep 2007 13:00:53 -0400 Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > Do these patches also cause the memory reclaimers to steer clear of
> > devices that are congested (and stop waiting on a congested device if
> > they see that it remains congested for a long period of time)? Most of
> > the collateral blocking I see tends to happen in memory allocation...
> > 
> 
> No, they don't attempt to do that, but I suspect they put in place
> infrastructure which could be used to improve direct-reclaimer latency.  In
> the throttle_vm_writeout() path, at least.
> 
> Do you know where the stalls are occurring?  throttle_vm_writeout(), or via
> direct calls to congestion_wait() from page_alloc.c and vmscan.c?  (running
> sysrq-w five or ten times will probably be enough to determine this)

Looking back, they were getting caught up in
balance_dirty_pages_ratelimited() and friends. See the attached
example...

Cheers
  Trond

--=-qxro6/a9LI9DLDRDrQ2v
Content-Disposition: inline
Content-Description: Attached message - [NFS] NFS on loopback locks up
	entire system(2.6.23-rc6)?
Content-Type: message/rfc822

Return-Path: <nfs-bounces@lists.sourceforge.net>
Received: from mail-imap2.uio.no ([unix socket]) by mail-imap2.uio.no
	(Cyrus v2.2.12) with LMTPA; Fri, 21 Sep 2007 02:22:53 +0200
X-Sieve: CMU Sieve 2.2
Delivery-date: Fri, 21 Sep 2007 02:22:53 +0200
Received: from mail-mx4.uio.no ([129.240.10.45]) by mail-imap2.uio.no with
	esmtp (Exim 4.67) (envelope-from <nfs-bounces@lists.sourceforge.net>) id
	1IYWIH-0002EY-Dh for trond.myklebust@fys.uio.no; Fri, 21 Sep 2007 02:22:53
	+0200
Received: from lists-outbound.sourceforge.net ([66.35.250.225]) by
	mail-mx4.uio.no with esmtp (Exim 4.67) (envelope-from
	<nfs-bounces@lists.sourceforge.net>) id 1IYWI9-0002zq-Gc; Fri, 21 Sep 2007
	02:22:53 +0200
Received: from sc8-sf-list2-new.sourceforge.net
	(sc8-sf-list2-new-b.sourceforge.net [10.3.1.94]) by
	sc8-sf-spam2.sourceforge.net (Postfix) with ESMTP id E1F8C12977; Thu, 20
	Sep 2007 17:22:33 -0700 (PDT)
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net) by sc8-sf-list2-new.sourceforge.net with esmtp
	(Exim 4.43) id 1IYWHp-0002td-Ub for nfs@lists.sourceforge.net; Thu, 20 Sep
	2007 17:22:25 -0700
Received: from wa-out-1112.google.com ([209.85.146.177]) by
	mail.sourceforge.net with esmtp (Exim 4.44) id 1IYWHu-0007tE-J1 for
	nfs@lists.sourceforge.net; Thu, 20 Sep 2007 17:22:30 -0700
Received: by wa-out-1112.google.com with SMTP id k22so868088waf for
	<nfs@lists.sourceforge.net>; Thu, 20 Sep 2007 17:22:26 -0700 (PDT)
Received: by 10.114.60.19 with SMTP id i19mr2779265waa.1190334146092; Thu,
	20 Sep 2007 17:22:26 -0700 (PDT)
Received: by 10.114.194.16 with HTTP; Thu, 20 Sep 2007 17:22:26 -0700 (PDT)
Message-ID: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
Date: Thu, 20 Sep 2007 17:22:26 -0700
From: "Chakri n" <chakriin5@gmail.com>
To: nfs@lists.sourceforge.net, Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org
MIME-Version: 1.0
Content-Disposition: inline
X-Spam-Score: 0.0 (/)
X-Spam-Report: Spam Filtering performed by sourceforge.net. See
	http://spamassassin.org/tag/ for more details. Report problems to
	http://sf.net/tracker/?func=add&group_id=1&atid=200001 0.0 RCVD_BY_IP      
	Received by mail server with no name
Subject: [NFS] NFS on loopback locks up entire system(2.6.23-rc6)?
X-BeenThere: nfs@lists.sourceforge.net
X-Mailman-Version: 2.1.8
Precedence: list
List-Id: "Discussion of NFS under Linux development, interoperability, and
	testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
X-UiO-SPF-Received: Received-SPF: pass (mail-mx4.uio.no: domain of
	lists.sourceforge.net designates 66.35.250.225 as permitted sender)
	client-ip=66.35.250.225; envelope-from=nfs-bounces@lists.sourceforge.net;
	helo=lists-outbound.sourceforge.net;
X-UiO-MailScanner: No virus found
X-UiO-ClamAV-Virus: No
X-UiO-Spam-info: not spam, SpamAssassin (score=-1.5, required=12.0,
	autolearn=disabled, AWL=-1.500)
X-UiO-Scanned: 3BB182E6ACF5F59BE0B44173855B9D28F5EB02CD
X-UiO-SPAM-Test: remote_host: 66.35.250.225 spam_score: -14 maxlevel 99990
	minaction 0 bait 0 mail/h: 6 total 73364 max/h 116 blacklist 0 greylist 0
	ratelimit 0
X-Evolution-Source: imap://trondmy@imap.uio.no/
Content-Transfer-Encoding: 7bit

Hi,

I am testing NFS on loopback locks up entire system with 2.6.23-rc6 kernel.

I have mounted a local ext3 partition using loopback NFS (version 3)
and started my test program. The test program forks 20 threads
allocates 10MB for each thread, writes & reads a file on the loopback
NFS mount. After running for about 5 min, I cannot even login to the
machine. Commands like ps etc, hang in a live session.

The machine is a DELL 1950 with 4Gig of RAM, so there is plenty of RAM
& CPU to play around and no other io/heavy processes are running on
the system.

vmstat output shows no buffers are actually getting transferred in or
out and iowait is 100%.

[root@h46 ~]# vmstat 1
procs -----------memory---------- ---swap-- -----io---- --system--
-----cpu------
 r  b    swpd       free       buff       cache   si   so   bi   bo
in     cs us sy id wa st
 0 24    116 110080  11132 3045664    0    0     0     0   28  345  0
1  0 99  0
 0 24    116 110080  11132 3045664    0    0     0     0    5  329  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0   26  336  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0    8  335  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0   26  352  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0    8  351  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0   23  358  0
1  0 99  0
 0 24    116 110080  11132 3045664    0    0     0     0   10  350  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0   26  363  0
0  0 100  0
 0 24    116 110080  11132 3045664    0    0     0     0    8  346  0
1  0 99  0
 0 24    116 110080  11132 3045664    0    0     0     0   26  360  0
0  0 100  0
 0 24    116 110080  11140 3045656    0    0     8     0   11  345  0
0  0 100  0
 0 24    116 110080  11140 3045664    0    0     0     0   27  355  0
0  2 97  0
 0 24    116 110080  11140 3045664    0    0     0     0    9  330  0
0  0 100  0
 0 24    116 110080  11140 3045664    0    0     0     0   26  358  0
0  0 100  0


The following is the backtrace of
1. one of the threads of my test program
2. nfsd daemon and
3. a generic command like pstree, after the machine hangs:
-------------------------------------------------------------
crash> bt 3252
PID: 3252   TASK: f6f3c610  CPU: 0   COMMAND: "test"
 #0 [f6bdcc10] schedule at c0624a34
 #1 [f6bdcc84] schedule_timeout at c06250ee
 #2 [f6bdccc8] io_schedule_timeout at c0624c15
 #3 [f6bdccdc] congestion_wait at c045eb7d
 #4 [f6bdcd00] balance_dirty_pages_ratelimited_nr at c045ab91
 #5 [f6bdcd54] generic_file_buffered_write at c0457148
 #6 [f6bdcde8] __generic_file_aio_write_nolock at c04576e5
 #7 [f6bdce40] try_to_wake_up at c042342b
 #8 [f6bdce5c] generic_file_aio_write at c0457799
 #9 [f6bdce8c] nfs_file_write at f8c25cee
#10 [f6bdced0] do_sync_write at c0472e27
#11 [f6bdcf7c] vfs_write at c0473689
#12 [f6bdcf98] sys_write at c0473c95
#13 [f6bdcfb4] sysenter_entry at c0404ddf
    EAX: 00000004  EBX: 00000013  ECX: a4966008  EDX: 00980000
    DS:  007b      ESI: 00980000  ES:  007b      EDI: a4966008
    SS:  007b      ESP: a5ae6ec0  EBP: a5ae6ef0
    CS:  0073      EIP: b7eed410  ERR: 00000004  EFLAGS: 00000246
crash> bt 3188
PID: 3188   TASK: f74c4000  CPU: 1   COMMAND: "nfsd"
 #0 [f6836c7c] schedule at c0624a34
 #1 [f6836cf0] __mutex_lock_slowpath at c062543d
 #2 [f6836d0c] mutex_lock at c0625326
 #3 [f6836d18] generic_file_aio_write at c0457784
 #4 [f6836d48] ext3_file_write at f8888fd7
 #5 [f6836d64] do_sync_readv_writev at c0472d1f
 #6 [f6836e08] do_readv_writev at c0473486
 #7 [f6836e6c] vfs_writev at c047358e
 #8 [f6836e7c] nfsd_vfs_write at f8e7f8d7
 #9 [f6836ee0] nfsd_write at f8e80139
#10 [f6836f10] nfsd3_proc_write at f8e86afd
#11 [f6836f44] nfsd_dispatch at f8e7c20c
#12 [f6836f6c] svc_process at f89c18e0
#13 [f6836fbc] nfsd at f8e7c794
#14 [f6836fe4] kernel_thread_helper at c0405a35
crash> ps|grep ps
    234      2   3  cb194000  IN   0.0       0      0  [khpsbpkt]
    520      2   0  f7e18c20  IN   0.0       0      0  [kpsmoused]
   2859      1   2  f7f3cc20  IN   0.1    9600   2040  cupsd
   3340   3310   0  f4a0f840  UN   0.0    4360    816  pstree
   3343   3284   2  f4a0f230  UN   0.0    4212    944  ps
crash> bt 3340
PID: 3340   TASK: f4a0f840  CPU: 0   COMMAND: "pstree"
 #0 [e856be30] schedule at c0624a34
 #1 [e856bea4] rwsem_down_failed_common at c04df6c0
 #2 [e856bec4] rwsem_down_read_failed at c0625c2a
 #3 [e856bedc] call_rwsem_down_read_failed at c0625c96
 #4 [e856bee8] down_read at c043c21a
 #5 [e856bef0] access_process_vm at c0462039
 #6 [e856bf38] proc_pid_cmdline at c04a1bbb
 #7 [e856bf58] proc_info_read at c04a2f41
 #8 [e856bf7c] vfs_read at c04737db
 #9 [e856bf98] sys_read at c0473c2e
#10 [e856bfb4] sysenter_entry at c0404ddf
    EAX: 00000003  EBX: 00000005  ECX: 0804dc58  EDX: 00000062
    DS:  007b      ESI: 00000cba  ES:  007b      EDI: 0804e0e0
    SS:  007b      ESP: bfa3afe8  EBP: bfa3d4f8
    CS:  0073      EIP: b7f64410  ERR: 00000003  EFLAGS: 00000246
----------------------------------------------------------

Any ideas what could potentially trigger this?

Please let me know if you would like to get any other specific details.

Thanks
--Chakri

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-qxro6/a9LI9DLDRDrQ2v--
