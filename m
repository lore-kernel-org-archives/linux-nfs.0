Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36544 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbLZSgV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 13:36:21 -0500
Received: by mail-oi0-f46.google.com with SMTP id o62so153049257oif.3
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 10:36:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
References: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
Date: Sat, 26 Dec 2015 13:36:20 -0500
Message-ID: <CAHQdGtSCn4bbx4xiyE7FXmWk3SCY81mvWLJz_1VDow9YtB5VgA@mail.gmail.com>
Subject: Re: [PATCH] nfs: do not deny execute access based on outdated mode in inode
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Donald Buczek <buczek@molgen.mpg.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 25, 2015 at 7:30 AM, Donald Buczek <buczek@molgen.mpg.de> wrote:
> This patch fixes a problem, that a nfs4 client incorrectly denies
> execute access based on outdated file mode (missing 'x' bit).
> After the mode on the server is 'fixed' (chmod +x) further execution
> attempts continue to fail, because the nfs ACCESS call updates
> the access parameter but not the mode parameter or the mode in
> the inode.
>
> The access check based on the file mode is not required, because
> the server already verified the clients rights.
>
> Remove the test.
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=109771
> Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
> ---
>  fs/nfs/dir.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index ce5a218..ffc25b0 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2481,9 +2481,6 @@ force_lookup:
>                         res = PTR_ERR(cred);
>         }
>  out:
> -       if (!res && (mask & MAY_EXEC) && !execute_ok(inode))
> -               res = -EACCES;
> -
>         dfprintk(VFS, "NFS: permission(%s/%lu), mask=0x%x, res=%d\n",
>                 inode->i_sb->s_id, inode->i_ino, mask, res);
>         return res;
>

My main question here is why the client isn't picking up the changed
mode bits here? All open() calls should be asking for the full set of
attributes as part of the OPEN COMPOUND rpc call.

Cheers
  Trond
