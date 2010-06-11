From: Fred Isaman <iisaman@umich.edu>
Subject: Re: SQUASHME pnfs-submit: write to MDS on DS commit verifier mismatch
Date: Fri, 11 Jun 2010 09:46:47 -0400
Message-ID: <AANLkTilBmSlxmu9RS_JfCmod8RnJnoOCMXMgcQ8Sjxgh@mail.gmail.com>
References: <1276205183-14014-1-git-send-email-andros@netapp.com>
	<1276205183-14014-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45998 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756382Ab0FKNqt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 09:46:49 -0400
Received: by bwz7 with SMTP id 7so334625bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 06:46:47 -0700 (PDT)
In-Reply-To: <1276205183-14014-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Andy.  I've squashed this into my just submitted patchset.

=46red

On Thu, Jun 10, 2010 at 5:26 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =A0fs/nfs/write.c | =A0 18 +++++++++++++-----
> =A01 files changed, 13 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 482d41e..a47f03d 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -422,6 +422,17 @@ static void nfs_inode_remove_request(struct nfs_=
page *req)
> =A0 =A0 =A0 =A0nfs_clear_request(req);
> =A0 =A0 =A0 =A0nfs_release_request(req);
> =A0}
> +static void
> +nfs_mark_request_nopnfs(struct nfs_page *req)
> +{
> + =A0 =A0 =A0 struct pnfs_layout_segment *lseg =3D req->wb_lseg;
> +
> + =A0 =A0 =A0 if (req->wb_lseg =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 req->wb_lseg =3D NULL;
> + =A0 =A0 =A0 put_lseg(lseg);
> + =A0 =A0 =A0 dprintk(" retry through MDS\n");
> +}
>
> =A0static void
> =A0nfs_mark_request_dirty(struct nfs_page *req)
> @@ -1463,11 +1474,7 @@ static void nfs_commit_release(void *calldata)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(long long)req_offset(=
req));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (status < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (req->wb_lseg) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
pnfs_layout_segment *lseg =3D req->wb_lseg;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 req->wb=
_lseg =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lse=
g(lseg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk=
(" retry through MDS\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_mar=
k_request_nopnfs(req);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs_ma=
rk_request_dirty(req);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto n=
ext;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -1487,6 +1494,7 @@ static void nfs_commit_release(void *calldata)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* We have a mismatch. Write the page =
again */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk(" mismatch\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_mark_request_nopnfs(req);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs_mark_request_dirty(req);
> =A0 =A0 =A0 =A0next:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs_clear_page_tag_locked(req);
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
