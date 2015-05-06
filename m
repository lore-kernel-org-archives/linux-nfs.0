Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36734 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbEFGP3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 02:15:29 -0400
MIME-Version: 1.0
In-Reply-To: <1428703236-24735-1-git-send-email-zab@redhat.com>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Wed, 6 May 2015 08:15:08 +0200
Message-ID: <CAHO5Pa0UEhOC3vqP9Nq4+gEH_OJPG6dgoLM9XbRLOfTRsRVSCw@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] simple copy offloading system call
To: Zach Brown <zab@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[CC += linux-api@vger.kernel.org]

Zach,

Since this is a kernel-user-space API change, please CC linux-api@.
The kernel source file Documentation/SubmitChecklist notes that all
Linux kernel patches that change userspace interfaces should be CCed
to linux-api@vger.kernel.org, so that the various parties who are
interested in API changes are informed. For further information, see
https://www.kernel.org/doc/man-pages/linux-api-ml.html

Thanks,

Michael




On Sat, Apr 11, 2015 at 12:00 AM, Zach Brown <zab@redhat.com> wrote:
> Hello everyone!
>
> Here's my current attempt at the most basic system call interface for
> offloading copying between files.  The system call and vfs function
> are relatively light wrappers around the file_operation method that
> does the heavy lifting.
>
> There was interest at LSF in getting the basic infrastructure merged
> before worrying about adding behavioural flags and more complicated
> implementations.  This series only offers a refactoring of the btrfs
> clone ioctl as an example of an implementation of the file
> copy_file_range method.
>
> I've added support for copy_file_range() to xfs_io in xfsprogs and
> have the start of an xfstest that tests the system call.  I'll send
> those to fstests@.
>
> So how does this look?
>
> Do we want to merge this and let the NFS and block XCOPY patches add
> their changes when they're ready?
>
> - z
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/
