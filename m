Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us01smtp2.synopsys.com ([198.182.44.80]:54117 "EHLO
	kiruna.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbZCCUHj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 15:07:39 -0500
From: Qiuyang Wu <Qiuyang.Wu@synopsys.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Qiuyang Wu <Qiuyang.Wu@synopsys.com>
CC: Jeff Moyer <jmoyer@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Tue, 3 Mar 2009 12:07:30 -0800
Subject: RE: pread/pwrite bug on linux?
Message-ID: <293BC70BB130E648A6631DB2F05B6E10019D6B288D@US01WXMBX1.internal.synopsys.com>
References: <b9ec419f0903021120g62814b6embe8eeaf354f8b535@mail.gmail.com>
	 <293BC70BB130E648A6631DB2F05B6E10019D6B224C@US01WXMBX1.internal.synopsys.com>
	 <x491vtebhq2.fsf@segfault.boston.devel.redhat.com>
	 <293BC70BB130E648A6631DB2F05B6E10019D6B277E@US01WXMBX1.internal.synopsys.com>
 <1236109038.9631.88.camel@heimdal.trondhjem.org>
In-Reply-To: <1236109038.9631.88.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,

Yes, I did compile it both on 32bit and 64bit, as well as run on both 32bit and 64bit, also tried what you suggested.

Unless there is something else I am missing, the only difference in behavior I saw were the number of iterations pwrite() goes thru before pread() fails... and in all cases, the file size is well under 2GB before pread() failed.

Thanks,
Qiuyang


-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent: Tuesday, March 03, 2009 11:37 AM
To: Qiuyang Wu
Cc: Jeff Moyer; linux-nfs@vger.kernel.org; linux-fsdevel@vger.kernel.org
Subject: RE: pread/pwrite bug on linux?

On Tue, 2009-03-03 at 10:47 -0800, Qiuyang Wu wrote:
> Hi Jeff,
>
> Attached the sample program. Should be able to compile as-is.
>
> Let me know your findings or need additional info.
>
> Thanks,
> Qiuyang

Are you compiling that on a 64-bit system? Otherwise you should note
that off_t is a signed 32-bit integer. You'd need to compile your test
program with -D_FILE_OFFSET_BITS=64 in order to make those pwrite()
calls work correctly past the 2Gb mark.
You also have potential 32/64-bit issues with the stat_file() routine.

Trond

> -----Original Message-----
> From: Jeff Moyer [mailto:jmoyer@redhat.com]
> Sent: Tuesday, March 03, 2009 10:10 AM
> To: Qiuyang Wu
> Cc: linux-nfs@vger.kernel.org; linux-fsdevel@vger.kernel.org
> Subject: Re: pread/pwrite bug on linux?
>
> Qiuyang Wu <Qiuyang.Wu@synopsys.com> writes:
>
> > Hi All,
> >
> > Are there any known bugs with pread/pwrite on RHEL Linux when the disk
> > partition is close to full?
> >
> > Reduced a complex application fatal down to a simple program just
> > opens a regular file and performs 1M sequential pwrite() of size 8KB
> > blocks; at every 100th write, does a pread() to load the very first
> > 8KB block and validate its content still matching what was originally
> > written.
>
> Could you attach your test program, please?
>
> > BEHAVIOR: pwrite() works for many iterations, then pread() suddenly
> > returns data of the requested size but filled with 0's, and strerror
> > shows errno="No such file or directory", condition
> >       if(size_to_read != pread(fd, buf, size_to_read, ...)) ...
> > is not triggered and application has to check errno immediately after
> > every call to pread.
>
> The value of errno is undefined if the pread call did not return -1.
>
> Cheers,
> Jeff

