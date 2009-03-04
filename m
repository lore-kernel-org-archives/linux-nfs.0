From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: pread/pwrite bug on linux?
Date: Wed, 04 Mar 2009 13:48:09 -0500
Message-ID: <x49k575jf9y.fsf@segfault.boston.devel.redhat.com>
References: <b9ec419f0903021120g62814b6embe8eeaf354f8b535@mail.gmail.com>
	<293BC70BB130E648A6631DB2F05B6E10019D6B224C@US01WXMBX1.internal.synopsys.com>
	<x491vtebhq2.fsf@segfault.boston.devel.redhat.com>
	<293BC70BB130E648A6631DB2F05B6E10019D6B277E@US01WXMBX1.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Qiuyang Wu <Qiuyang.Wu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52103 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112AbZCDSsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2009 13:48:13 -0500
In-Reply-To: <293BC70BB130E648A6631DB2F05B6E10019D6B277E-uiPIUNf6hlr3OT/vyeh27fufCSb+aD3WLzEdoUbNIic@public.gmane.org>
	(Qiuyang Wu's message of "Tue, 3 Mar 2009 10:47:24 -0800")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
