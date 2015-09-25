Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.vodafone.ie ([213.233.128.44]:52357 "EHLO
	mail2.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbbIYV6r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 17:58:47 -0400
Subject: Re: [PATCH v3 8/9] vfs: copy_file_range() can do a pagecache copy
 with splice
To: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443214096-12769-9-git-send-email-Anna.Schumaker@Netapp.com>
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <5605C392.80008@draigBrady.com>
Date: Fri, 25 Sep 2015 22:58:42 +0100
MIME-Version: 1.0
In-Reply-To: <1443214096-12769-9-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25/09/15 21:48, Anna Schumaker wrote:
> The NFS server will need some kind offallback for filesystems that don't
> have any kind of copy acceleration, and it should be generally useful to
> have an in-kernel copy to avoid lots of switches between kernel and user
> space.
> 
> I make this configurable by adding two new flags.  Users who only want a
> reflink can pass COPY_FR_REFLINK, and users who want a full data copy can
> pass COPY_FR_COPY.  The default (flags=0) means to first attempt a
> reflink, but use the pagecache if that fails.
> 
> I moved the rw_verify_area() calls into the fallback code since some
> filesystems can handle reflinking a large range.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Reviewed-by: Pádraig Brady <P@draigBrady.com>

LGTM. For my reference, for cp(1), mv(1), install(1), this will avoid
user space copies in the normal case, client side copies in the network
file system case, and provide a more generalized interface to reflink().

coreutils pseudo code is:

  unsigned int cfr_flags = COPY_FR_COPY;
  if (mode == mv)
    cfr_flags = 0; /* reflink falling back to normal */
  else if (mode == cp) {
    if --reflink || --reflink==always
      cfr_flags = COPY_FR_REFLINK;
    else if --reflink==auto
      cfr_flags = 0; /* reflink falling back to normal */
  }
  if vfs_copy_file_range(..., cfr_flags) == ENOTSUP
    normal_user_space_copy();

thanks,
Pádraig.
