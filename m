Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:22046 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750945AbcIPVOL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 17:14:11 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Fields Bruce James <bfields@fieldses.org>
Subject: Re: [PATCH v3 2/9] nfs: check for POSIX lock capability on server
 even for flock locks
Date: Fri, 16 Sep 2016 21:14:06 +0000
Message-ID: <AEF00C6F-ECDD-4292-BDC2-A635D4EBB1B4@primarydata.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
 <1474057631-31209-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057631-31209-3-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 16, 2016, at 16:27, Jeff Layton <jlayton@redhat.com> wrote:
>=20
> We may end up in here with a FL_FLOCK lock request. We translate those
> to whole-file NFSv4 locks and send them on to the server, so we need to
> verify that the server supports them no matter what sort of lock request
> this is.
>=20
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/nfs4proc.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9d38366666f4..a0f25185c78c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6135,8 +6135,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *stat=
e, int cmd, struct file_lock
> =09unsigned char fl_flags =3D request->fl_flags;
> =09int status =3D -ENOLCK;
>=20
> -=09if ((fl_flags & FL_POSIX) &&
> -=09=09=09!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
> +=09if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
> =09=09goto out;
> =09/* Is this a delegated open? */
> =09status =3D nfs4_set_lock_state(state, request);
> --=20
> 2.7.4

The ability to support FL_FLOCK locks does not depend on the server=92s sup=
port for POSIX locking semantics. FL_FLOCK can also use stacked lock semant=
ics, precisely because they always cover the whole file.

