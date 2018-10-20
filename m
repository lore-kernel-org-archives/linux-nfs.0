Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45590 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726176AbeJTMOc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Oct 2018 08:14:32 -0400
Date: Sat, 20 Oct 2018 05:05:30 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        fweimer@redhat.com, smfrench@gmail.com
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Message-ID: <20181020040530.GG32577@ZenIV.linux.org.uk>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181019153018.32507-2-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> Allow copy_file_range to copy between different superblocks but only
> of the same file system types. This feature was of interest to CIFS
> as well as NFS.

> +	if (file_out->f_op->copy_file_range &&
> +			(file_in->f_op->copy_file_range ==
> +				file_out->f_op->copy_file_range)) {

That is seriously asking for trouble.  If at some point we add
a library function usable as ->copy_file_range() instance, this
will turn into a hard-to-spot problem.

Comparing methods like that is best avoided.  If you want to compare
fs types, do just that - it's not hard.

Another potential issue here is the interplay with local filesystems
using vfs_clone_file_prep_inodes() (or Darrick's series lifting that
into generic code).  There we assume the same block size on both
sides; that is automatically true if they live on the same superblock,
but with your changes it's no longer true.
