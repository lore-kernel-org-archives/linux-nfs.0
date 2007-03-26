From: "Phy Prabab" <phyprabab@gmail.com>
Subject: Re: Opps in 2.6.21-rc4 nfsd
Date: Mon, 26 Mar 2007 00:07:13 -0700
Message-ID: <2fe399760703260007u7cea0599y7bcce8f779e02c71@mail.gmail.com>
References: <2fe399760703221224g40fc44ddof41d1fcd442612d5@mail.gmail.com>
	<20070323152913.GH752@stusta.de>
	<2fe399760703230845s4f652df0v9fd57e1aa7943e4e@mail.gmail.com>
	<17927.6359.721594.133569@notabene.brown>
	<17927.7414.722426.438730@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVjIP-0001Of-14
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 00:07:13 -0700
Received: from wx-out-0506.google.com ([66.249.82.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVjIQ-0003Ov-0l
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 00:07:15 -0700
Received: by wx-out-0506.google.com with SMTP id i30so3022942wxd
	for <nfs@lists.sourceforge.net>; Mon, 26 Mar 2007 00:07:13 -0700 (PDT)
In-Reply-To: <17927.7414.722426.438730@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Opps, forgot, this is for 2.6.20.x, guess I'll wait for the updated patch.

Thanks!
Phy

On 3/25/07, Neil Brown <neilb@suse.de> wrote:
> On Monday March 26, neilb@suse.de wrote:
> >
> > I'll try to have a patch for you to try on 2.6.21rc4 shortly.
> >
>
> This patch should remove the Oops, but I have a suspicion that
> something else is wrong, so I'd be very interested if you could run
> with this for a few days and report the results.
>
> NeilBrown
>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./fs/nfsd/nfsfh.c |   37 +++++++++++++++++++++++++++++++++++--
>  1 file changed, 35 insertions(+), 2 deletions(-)
>
> diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
> --- .prev/fs/nfsd/nfsfh.c       2007-03-26 10:51:01.000000000 +1000
> +++ ./fs/nfsd/nfsfh.c   2007-03-26 11:04:20.000000000 +1000
> @@ -324,7 +324,7 @@ fh_compose(struct svc_fh *fhp, struct sv
>          *
>          */
>
> -       u8 version = 1;
> +       u8 version;
>         u8 fsid_type = 0;
>         struct inode * inode = dentry->d_inode;
>         struct dentry *parent = dentry->d_parent;
> @@ -342,12 +342,45 @@ fh_compose(struct svc_fh *fhp, struct sv
>          * the reference filehandle (if it is in the same export)
>          * or the export options.
>          */
> + retry:
> +       version = 1;
>         if (ref_fh && ref_fh->fh_export == exp) {
>                 version = ref_fh->fh_handle.fh_version;
>                 if (version == 0xca)
>                         fsid_type = FSID_DEV;
> -               else
> +               else {
>                         fsid_type = ref_fh->fh_handle.fh_fsid_type;
> +                       /* need to check that this type works for this
> +                        * export point.  As the lookup was done with
> +                        * help from user-space, there is no guarantee
> +                        */
> +                       if (ref_fh == fhp)
> +                               fh_put(ref_fh);
> +                       ref_fh = NULL;
> +                       switch(fsid_type) {
> +                       case FSID_DEV:
> +                               if (!old_valid_dev(ex_dev))
> +                                       goto retry;
> +                               break;
> +                       case FSID_NUM:
> +                               if (! (exp->ex_flags & NFSEXP_FSID))
> +                                       goto retry;
> +                               break;
> +                       case FSID_MAJOR_MINOR:
> +                       case FSID_ENCODE_DEV:
> +                               break;
> +                       case FSID_UUID8:
> +                       case FSID_UUID16:
> +                               if (!root_export)
> +                                       goto retry;
> +                               /* fall through */
> +                       case FSID_UUID4_INUM:
> +                       case FSID_UUID16_INUM:
> +                               if (exp->ex_uuid == NULL)
> +                                       goto retry;
> +                               break;
> +                       }
> +               }
>                 /* We know this version/type works for this export
>                  * so there is no need for further checks.
>                  */
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
