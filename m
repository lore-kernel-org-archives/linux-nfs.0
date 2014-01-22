Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47619 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbaAVR0F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jan 2014 12:26:05 -0500
Date: Wed, 22 Jan 2014 12:26:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs] nfs4.1 server: fix typos related to file layout
Message-ID: <20140122172603.GA12719@fieldses.org>
References: <1390247179-2617-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1390247179-2617-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied, thanks.--b.

On Mon, Jan 20, 2014 at 02:46:19PM -0500, Weston Andros Adamson wrote:
> Since the new .x it's "FATTR4_FS_LAYOUT_TYPES", not "FATTR4_FS_LAYOUT_TYPE"
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  nfs4.1/fs.py | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/nfs4.1/fs.py b/nfs4.1/fs.py
> index 0eedb3f..16e9e7c 100644
> --- a/nfs4.1/fs.py
> +++ b/nfs4.1/fs.py
> @@ -353,7 +353,7 @@ class FSObject(object):
>          NOTE permissions checking on the range has already been done
>          """
>          fs = self.fs
> -        if not fs.fattr4_supported_attrs & (1 << FATTR4_FS_LAYOUT_TYPE):
> +        if not fs.fattr4_supported_attrs & (1 << FATTR4_FS_LAYOUT_TYPES):
>              raise NFS4Error(NFS4ERR_LAYOUTUNAVAILABLE)
>          try:
>              types = fs.fattr4_fs_layout_type
> @@ -376,7 +376,7 @@ class FSObject(object):
>          if arg.loca_reclaim:
>              # STUB - this is just not supported
>              raise NFS4Error(NFS4ERR_NO_GRACE)
> -        if not fs.fattr4_supported_attrs & (1 << FATTR4_FS_LAYOUT_TYPE):
> +        if not fs.fattr4_supported_attrs & (1 << FATTR4_FS_LAYOUT_TYPES):
>              raise NFS4Error(NFS4ERR_LAYOUTUNAVAILABLE)
>          if not self.current_layout:
>              raise NFS4Error(NFS4ERR_BADLAYOUT, tag="File has no layout")
> @@ -1280,7 +1280,7 @@ class BlockLayoutFS(FileSystem):
>          FileSystem.__init__(self, objclass=LayoutFSObj)
>          self.fsid = (3, fsid)
>          self.fattr4_fs_layout_type = [LAYOUT4_BLOCK_VOLUME]
> -        self.fattr4_supported_attrs |= 1 << FATTR4_FS_LAYOUT_TYPE
> +        self.fattr4_supported_attrs |= 1 << FATTR4_FS_LAYOUT_TYPES
>          self.fattr4_layout_blksize = 4096
>          self.fattr4_supported_attrs |= 1 << FATTR4_LAYOUT_BLKSIZE
>          self.fattr4_maxwrite = 4096
> @@ -1428,7 +1428,7 @@ class FileLayoutFS(FileSystem):
>          FileSystem.__init__(self, objclass=FSLayoutFSObj)
>          self.fsid = (2, fsid)
>          self.fattr4_fs_layout_type = [LAYOUT4_NFSV4_1_FILES]
> -        self.fattr4_supported_attrs |= 1 << FATTR4_FS_LAYOUT_TYPE
> +        self.fattr4_supported_attrs |= 1 << FATTR4_FS_LAYOUT_TYPES
>          self.fattr4_maxwrite = 8192
>          self.fattr4_maxread = 8192
>          self.fattr4_supported_attrs |= 1 << FATTR4_MAXWRITE
> -- 
> 1.8.3.4 (Apple Git-47)
> 
