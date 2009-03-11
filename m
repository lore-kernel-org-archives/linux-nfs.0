From: Qiuyang Wu <Qiuyang.Wu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: RE: pread/pwrite bug on linux?
Date: Tue, 10 Mar 2009 17:37:07 -0700
Message-ID: <293BC70BB130E648A6631DB2F05B6E10019D89830F@US01WXMBX1.internal.synopsys.com>
References: <b9ec419f0903021120g62814b6embe8eeaf354f8b535@mail.gmail.com>
	<293BC70BB130E648A6631DB2F05B6E10019D6B224C@US01WXMBX1.internal.synopsys.com>
	<x491vtebhq2.fsf@segfault.boston.devel.redhat.com>
	<293BC70BB130E648A6631DB2F05B6E10019D6B277E@US01WXMBX1.internal.synopsys.com>
 <x49k575jf9y.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from us01smtp2.synopsys.com ([198.182.44.80]:56454 "EHLO
	kiruna.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbZCKAhR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:37:17 -0400
In-Reply-To: <x49k575jf9y.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Thanks for the responses.

Just FYI that the bug was acknowledged, also it seems RH v5.3 does not have the problem...



-----Original Message-----
From: Jeff Moyer [mailto:jmoyer@redhat.com]
Sent: Wednesday, March 04, 2009 10:48 AM
To: Qiuyang Wu
Cc: linux-nfs@vger.kernel.org; linux-fsdevel@vger.kernel.org
Subject: Re: pread/pwrite bug on linux?

Qiuyang Wu <Qiuyang.Wu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org> writes:

> Hi Jeff,
>
> Attached the sample program. Should be able to compile as-is.
>
> Let me know your findings or need additional info.

I am not able to reproduce the problem.  I tried with a RHEL 4 system,
using exactly the kernel you listed (2.6.9-55.EL) on an i386 system.  I
tried against ext2, ext3, and an nfs mount exported from a RHEL 5
system.  I should note that I modified your program to detect short
writes and continue instead of reporting a bogus error.  I'll reiterate
that the value of errno is undefined if the library/system call did not
return -1.

I noticed that your test case used NFS.  What NFS server were you using?
Can you think of any other details that might affect the test?

Thanks,
Jeff
