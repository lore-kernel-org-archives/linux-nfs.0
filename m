Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57101 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbbITFFH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Sep 2015 01:05:07 -0400
From: Neil Brown <neilb@suse.de>
To: Kinglong Mee <kinglongmee@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 20 Sep 2015 07:05:01 +0200
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH] nfs: Fix open state losing after delegation return
In-Reply-To: <55FA8D22.2010003@gmail.com>
References: <55FA8D22.2010003@gmail.com>
Message-ID: <87fv294r5u.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Kinglong Mee <kinglongmee@gmail.com> writes:

> After delegation return caused by setting file mode,=20
> client lost the open state,  DESTROY_CLIENTID will=20
> get error NFS4ERR_CLIENTID_BUSY from server.
>
> The delegation_type passed to nfs4_open_recover_helper
> with NFS4_OPEN_CLAIM_DELEG_CUR_FH is never set.
>
> Reproduce steps,
> # mount -t nfs nfs-server:/ /mnt/
> # ./delegation_test /mnt/
> # umount /mnt    <--- costs 10 seconds
>
> The delegation_test.c is,
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/types.h>
> #include <unistd.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <error.h>
>
> int main(int argc, char **argv)
> {
>         int fd1, fd2;
>         char fname1[1024], fname2[1024];
>         struct stat sb;
>
>         if (argc < 2)
>                 return -1;
>
>         sprintf(fname1, "%s/test1", argv[1]);
>         sprintf(fname2, "%s/test2", argv[1]);
>
>         fd1 =3D open(fname1, O_RDONLY);
>         fd2 =3D open(fname2, O_RDONLY);
>
>         fstat(fd1, &sb);
>         fchmod(fd1, sb.st_mode + 1);
>
>         close(fd1);
>         close(fd2);
>
>         return 0;
> }
>
> Fixes: 39f897fdbd ("NFSv4: When returning a delegation, don't reclaim an =
incompatible open mode.")
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/nfs4proc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 693b903..472a52f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1576,8 +1576,7 @@ static int nfs4_open_recover_helper(struct nfs4_ope=
ndata *opendata, fmode_t fmod
>  	struct nfs4_state *newstate;
>  	int ret;
>=20=20
> -	if ((opendata->o_arg.claim =3D=3D NFS4_OPEN_CLAIM_DELEGATE_CUR ||
> -	     opendata->o_arg.claim =3D=3D NFS4_OPEN_CLAIM_DELEG_CUR_FH) &&
> +	if (opendata->o_arg.claim =3D=3D NFS4_OPEN_CLAIM_DELEGATE_CUR &&
>  	    (opendata->o_arg.u.delegation_type & fmode) !=3D fmode)
>  		/* This mode can't have been delegated, so we must have
>  		 * a valid open_stateid to cover it - not need to reclaim.
> --=20
> 2.5.0

This patches doesn't look right to me.  It isn't at all clear why the
change given addresses the symptoms described.

However looking back at my patch (39f897fdbd) it looks really wrong and
I cannot imagine how I missed the problem when I submitted it.

nfs4_open_recover assumes that if nfs4_open_recover_helper returns zero,
the 'newstate' has been given a value and if that doesn't match 'state'
it returns -ESTALE.

However with my patch, nfs4_open_recovery_helper can return zero and
leave 'newstate' uniitialised.  I cannot even see how that passed
testing :-(

You could maybe fix with

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 693b903b48bd..6899197ff1c3 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1604,7 +1604,7 @@ static int nfs4_open_recover_helper(struct nfs4_opend=
ata *opendata, fmode_t fmod
=20
 static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_s=
tate *state)
 {
=2D	struct nfs4_state *newstate;
+	struct nfs4_state *newstate =3D state;
 	int ret;
=20
 	/* Don't trigger recovery in nfs_test_and_clear_all_open_stateid */

but I'm not at all sure I like that.  I'll try to find time to look at
the code properly and make a more concrete proposal - and to test with
your test case too.  However you didn't give details on the mount: I
assume it was a 4.1 mount?  Was it against the Linux nfs server or
something else?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV/j59AAoJEDnsnt1WYoG5Yz8P/39/dXcS2YR+nMmSU4cRYoOU
+3vCbw2tQ49GN7ke0LVpqZCS3C0SUmCf1HU4z/gHh8vWenhAW58cjkooiYxMo6pa
Wtrf/+qd68wxyfUYVHaRgg4LL0AiQF4k+92cj9dtA0HrYQE12UDmg7r2tQ3ekTiE
jgyfOkT84oXjFGsMXgWXigknVwqMqJuw7Wo425O0ts26gY9IJ5ej2eYSlzcouDno
vexSQLU8huSSn+XXf9kXR9DXVMJbY5sfty2HNLi1SxBJ+K8BMYyw5fX23uZSVR0E
PdqcJM0VkfNpOmH5i6wyctx17LcFU8Q8xwGZLgAer8u2985wwMxXUndWbkYRTGw+
IgSfPZuuP1ckuo+KWKI0qYVOTR5qYmpceEZbVO4uza+uG5qFaCV/QEdBC2/sTBG7
NlzpylABuzaVW/DQ22a7KqCTfIDlhdHZBLkMgZ9YAzW0A2yJhceX/wtI4m6vjb3p
DaJVurVnp3bsIaJf5IuUo0yhDfaJHEC89IXr9gdKq+UUH3kWDMy8eJpgf1gwTNQK
hpOjq5p6cLa9niuZBdjiRDpmC2Kw0Ua82AnyBNb7oT0qLlJ3den2M7iRkD6bfV2K
aHoUa7Pt9Yur+AlcbHMXz85PaM2lpYoV4oSjsx6BW6dBUY7JjfJHqeMgC0j0xPSV
Za9GxTu8OONyq0vRdPSs
=RL7p
-----END PGP SIGNATURE-----
--=-=-=--
