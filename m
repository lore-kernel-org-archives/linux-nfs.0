From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: pread/pwrite bug on linux?
Date: Tue, 03 Mar 2009 13:10:13 -0500
Message-ID: <x491vtebhq2.fsf@segfault.boston.devel.redhat.com>
References: <b9ec419f0903021120g62814b6embe8eeaf354f8b535@mail.gmail.com>
	<293BC70BB130E648A6631DB2F05B6E10019D6B224C@US01WXMBX1.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Qiuyang Wu <Qiuyang.Wu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58865 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbZCCSKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2009 13:10:19 -0500
In-Reply-To: <293BC70BB130E648A6631DB2F05B6E10019D6B224C-uiPIUNf6hlr3OT/vyeh27fufCSb+aD3WLzEdoUbNIic@public.gmane.org>
	(Qiuyang Wu's message of "Mon, 2 Mar 2009 13:53:19 -0800")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Qiuyang Wu <Qiuyang.Wu-HKixBCOQz3hWk0Htik3J/w@public.gmane.org> writes:

> Hi All,
>
> Are there any known bugs with pread/pwrite on RHEL Linux when the disk
> partition is close to full?
>
> Reduced a complex application fatal down to a simple program just
> opens a regular file and performs 1M sequential pwrite() of size 8KB
> blocks; at every 100th write, does a pread() to load the very first
> 8KB block and validate its content still matching what was originally
> written.

Could you attach your test program, please?

> BEHAVIOR: pwrite() works for many iterations, then pread() suddenly
> returns data of the requested size but filled with 0's, and strerror
> shows errno="No such file or directory", condition
>       if(size_to_read != pread(fd, buf, size_to_read, ...)) ...
> is not triggered and application has to check errno immediately after
> every call to pread.

The value of errno is undefined if the pread call did not return -1.

Cheers,
Jeff
