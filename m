Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:38026 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbbBXDJL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 22:09:11 -0500
Received: by mail-vc0-f170.google.com with SMTP id hq12so9086046vcb.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 19:09:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
Date: Mon, 23 Feb 2015 22:09:09 -0500
Message-ID: <CAHQdGtR1GawAD6yAidTZJM68TzaBrieX86C+eDE08HQF_0Jg4w@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFS: Don't invalidate a submounted dentry in nfs_prime_dcache()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Nix <nix@esperi.org.uk>, Neil Brown <neilb@suse.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 23, 2015 at 7:14 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If we're traversing a directory which contains a submounted filesystem,
> or one that has a referral, the NFS server that is processing the READDIR
> request will often return information for the underlying (mounted-on)
> directory. It may, or may not, also return filehandle information.
>
> If this happens, and the lookup in nfs_prime_dcache() returns the
> dentry for the submounted directory, the filehandle comparison will
> fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
> ("vfs: Lazily remove mounts on unlinked files and directories."), this
> means the entire subtree is unmounted.
>
> The following minimal patch addresses this problem by punting on
> the invalidation if there is a submount.
>
> Kudos to Neil Brown <neilb@suse.de> for having tracked down this
> issue (see link).
>
> Reported-by: Nix <nix@esperi.org.uk>
> Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
> Cc: stable@vger.kernel.org # 3.18+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/dir.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 9b0c55cb2a2e..0da617a61c0b 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -479,6 +479,10 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
>
>         dentry = d_lookup(parent, &filename);
>         if (dentry != NULL) {
> +               /* Is there a mountpoint here? If so, just exit */
> +               if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
> +                                       &entry->fattr->fsid))
> +                       goto out;
>                 if (nfs_same_file(dentry, entry)) {
>                         nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>                         status = nfs_refresh_inode(dentry->d_inode, entry->fattr);
> --

...and this of course needs the test for NFS_ATTR_FATTR_FSID from
3/3.... I've updated.



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
