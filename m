Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:59413 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab1HCBsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 21:48:10 -0400
Date: Tue, 2 Aug 2011 21:48:08 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110803014808.GA4692@merit.edu>
References: <20110729191341.GC23061@merit.edu>
 <1311988172.16078.15.camel@lade.trondhjem.org>
 <20110730032621.GB25188@merit.edu>
 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
 <1312233006.23392.17.camel@lade.trondhjem.org>
 <1312238117.23392.19.camel@lade.trondhjem.org>
 <20110802022144.GA18157@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
 <20110802032320.GA18296@merit.edu>
 <1312288134.4616.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312288134.4616.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's what the test is doing.  It does multiple parallel instances of this,
each one doing thousands of the following in a loop.  Console output with
mutex and lock debug is in
http://www.citi.umich.edu/projects/nfsv4/pnfs/block/download/console.txt

getpid()                                = 2431
open("t_mtab~2431", O_WRONLY|O_CREAT, 0) = 3
close(3)                                = 0
link("t_mtab~2431", "t_mtab~")          = 0
unlink("t_mtab~2431")                   = 0
open("t_mtab~", O_WRONLY)               = 3
fcntl(3, F_SETLK, {type=F_WRLCK, whence=SEEK_SET, start=0, len=0}) = 0
close(3)                                = 0
brk(0)                                  = 0x19ab000
brk(0x19cc000)                          = 0x19cc000
brk(0)                                  = 0x19cc000
open("t_mtab", O_RDONLY)                = 3
open("t_mtab.tmp", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 4
read(3, "/proc on /proc type proc (rw,rel"..., 4096) = 2598
write(4, "/proc on /proc type proc (rw,rel"..., 2598) = 2598
read(3, "", 4096)                       = 0
close(3)                                = 0
fchmod(4, 0644)                         = 0
close(4)                                = 0
stat("t_mtab", {st_mode=S_IFREG|0644, st_size=2598, ...}) = 0
chown("t_mtab.tmp", 99, 0)              = -1 EINVAL (Invalid argument)
rename("t_mtab.tmp", "t_mtab")          = 0
unlink("t_mtab~")                       = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd95cd76000
write(1, "completed 1 iterations\n", 23) = 23
exit_group(0)                           = ?
