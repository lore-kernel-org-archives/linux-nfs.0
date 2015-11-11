Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33304 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbbKKOxk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2015 09:53:40 -0500
Date: Wed, 11 Nov 2015 08:53:37 -0600
From: Eric Biggers <ebiggers3@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v9 0/4] VFS: In-kernel copy system call
Message-ID: <20151111145337.GA2392@zzz>
References: <1447192413-15376-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447192413-15376-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2015 at 04:53:30PM -0500, Anna Schumaker wrote:
>	out:
>		fdput(f_in);
>	out1:
>		fdput(f_out);

The fdput()s are in the wrong order.  fdget(f_in) is first at the beginning, so
fdput(f_in) needs to be last at the end.

>       /* this could be relaxed once a method supports cross-fs copies */
>       if (inode_in->i_sb != inode_out->i_sb)
>               return -EXDEV;

This allows the same superblock but different mounts --- is that intentional?
The commit message says otherwise: it says the vfs entry point requires the same
superblock and mount.


Was there a decision made on FMODE_PREAD and FMODE_PWRITE?  To me it seems
logical that the if the user explicitly specifies an offset, then the
corresponding mode should be checked.  That would check whether the file is
seekable or not, I believe.  Note that e.g. sys_sendfile() does the same thing.
