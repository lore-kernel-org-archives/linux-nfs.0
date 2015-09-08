Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:57663 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbbIHSXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2015 14:23:33 -0400
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
To: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>,
        <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <55EEFCEE.5090000@draigBrady.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55EF279B.3020101@Netapp.com>
Date: Tue, 8 Sep 2015 14:23:23 -0400
MIME-Version: 1.0
In-Reply-To: <55EEFCEE.5090000@draigBrady.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/08/2015 11:21 AM, Pádraig Brady wrote:
> On 04/09/15 21:16, Anna Schumaker wrote:
>> Copy system calls came up during Plumbers a couple of weeks ago, because
>> several filesystems (including NFS and XFS) are currently working on copy
>> acceleration implementations.  We haven't heard from Zach Brown in a while,
>> so I volunteered to push his patches upstream so individual filesystems
>> don't need to keep writing their own ioctls.
> 
> Just mentioning that this is just pertaining to the data, not the metadata.
> Providing metadata copying facilities would be _very_ useful, as
> most file system specific details relate to the metadata, and having
> VFS operations for that would avoid the plethora of details in each userspace tool,
> and theoretically support translations between disparate metadata.

Metadata copying could be added later if somebody really wants it.

> 
>> The first three patches are a simple reposting of Zach's patches from several
>> months ago, with one minor error code fix.  The remaining patches add in a
>> fallback mechanism when filesystems don't provide a copy function.  This is
>> especially useful when doing a server-side copy on NFS (using the new COPY
>> operation in NFS v4.2).  This fallback can be disabled by passing the flag
>> COPY_REFLINK to the system call.
> 
> I see copy_file_range() is a reflink() on BTRFS?
> That's a bit surprising, as it avoids the copy completely.
> cp(1) for example considered doing a BTRFS clone by default,
> but didn't due to expectations that users actually wanted
> the data duplicated on disk for resilience reasons,
> and for performance reasons so that write latencies were
> restricted to the copy operation, rather than being
> introduced at usage time as the dest file is CoW'd.
> 
> If reflink() is a possibility for copy_file_range()
> then could it be done optionally with a flag?

The idea is that filesystems get to choose how to handle copies in the default case.  BTRFS could do a reflink, but NFS could do a server side copy instead.  I can change the default behavior to only do a data copy (unless the reflink flag is specified) instead, if that is desirable.

What does everybody think?

Anna

> 
> thanks,
> Pádraig
> 

