Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:52933 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab1LAGcO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 01:32:14 -0500
Date: Thu, 1 Dec 2011 00:31:58 -0600
From: Tyler Hicks <tyhicks@canonical.com>
To: Chris Dunlop <chris@onthe.net.au>
Cc: David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201063157.GA495@boyd>
References: <20111130071319.GA16711@onthe.net.au>
 <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
 <24960.1322643283@redhat.com>
 <20111201004709.GA26085@onthe.net.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
In-Reply-To: <20111201004709.GA26085@onthe.net.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2011-12-01 11:47:09, Chris Dunlop wrote:
> On Wed, Nov 30, 2011 at 08:54:43AM +0000, David Howells wrote:
> > Chris Dunlop <chris@onthe.net.au> wrote:
> >=20
> >> To avoid other people further wasting their and your time on
> >> exactly the same thing future, how something like the following
> >> patch, based on your comment in:
> >>=20
> >> http://article.gmane.org/gmane.linux.nfs/40370
> >>=20
> >> ...and, if that's acceptable, is it worthwhile doing for the
> >> other file systems which are likewise currently vulnerable when
> >> abused by broken layered file systems?
> >=20
> > Also, this may get fixed by Al's atomic open patches - but obviously it=
 hasn't
> > been yet...
> >=20
> >> Don't oops when abused by broken layered file systems
> >>=20
> >> Signed-off-by: Chris Dunlop <chris@onthe.net.au>
> >=20
> > Acked-by: David Howells <dhowells@redhat.com>
> >=20
> > It's also worth printing a message - this *is* a kernel bug of some des=
cription
> > if it happens.
>=20
> Like the below?  This covers the d_revalidate for 9p, afs, coda,
> hfs, ncpfs, proc, sysfs.

I don't like the looks of this patch. It makes sense for NFS to error
out of d_revalidate() when passed a NULL nameidata pointer because NFS
actually uses the nameidata to do something useful. That can't be said
about the other filesystems in this patch.

Why not handle the other filesystems like the previous fixes you
referenced in your original email by checking for a non-NULL nd like
this:

	if (nd && nd->flags & LOOKUP_RCU)
		return -ECHILD;

I'm also not sure about the printk in the NFS case. Instead of littering
the logs, we should probably just disallow the stacked filesystem (are
we talking about eCryptfs here?) from mounting on top of NFS in the
first place.

Tyler

>=20
> Note:  jfs isn't susceptible to this problem, but the resolution
> doesn't look like the other file systems, and from the comment
> I'm not sure if the problem was really understood and if it's
> doing the right thing:
>=20
> static int jfs_ci_revalidate(struct dentry *dentry, struct nameidata *nd)
> {
>         ...
>         /*
>          * This may be nfsd (or something), anyway, we can't see the
>          * intent of this. So, since this can be for creation, drop it.
>          */
>         if (!nd)
>                 return 0;
>=20
>         /*
>          * Drop the negative dentry, in order to make sure to use the
>          * case sensitive name which is specified by user if this is
>          * for creation.
>          */
>         if (nd->flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
>                 return 0;
>         ...
> }
>=20
> Chris.
>=20
> ----------------------------------------------------------------------
> Don't oops when abused by broken layered file systems
>=20
> Signed-off-by: Chris Dunlop <chris@onthe.net.au>
> ---
>  fs/9p/vfs_dentry.c    |    6 ++++++
>  fs/afs/dir.c          |    6 ++++++
>  fs/coda/dir.c         |    6 ++++++
>  fs/hfs/sysdep.c       |    6 ++++++
>  fs/ncpfs/dir.c        |    6 ++++++
>  fs/nfs/dir.c          |   12 ++++++++++++
>  fs/proc/proc_sysctl.c |    5 +++++
>  fs/sysfs/dir.c        |    6 ++++++
>  8 files changed, 53 insertions(+), 0 deletions(-)
>=20
> diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
> index e022890..3b082dc 100644
> --- a/fs/9p/vfs_dentry.c
> +++ b/fs/9p/vfs_dentry.c
> @@ -106,6 +106,12 @@ static int v9fs_lookup_revalidate(struct dentry *den=
try, struct nameidata *nd)
>  	struct inode *inode;
>  	struct v9fs_inode *v9inode;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "v9fs_lookup_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> diff --git a/fs/afs/dir.c b/fs/afs/dir.c
> index 1b0b195..4003d76 100644
> --- a/fs/afs/dir.c
> +++ b/fs/afs/dir.c
> @@ -607,6 +607,12 @@ static int afs_d_revalidate(struct dentry *dentry, s=
truct nameidata *nd)
>  	void *dir_version;
>  	int ret;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "afs_d_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> diff --git a/fs/coda/dir.c b/fs/coda/dir.c
> index 0239433..ede8e77 100644
> --- a/fs/coda/dir.c
> +++ b/fs/coda/dir.c
> @@ -544,6 +544,12 @@ static int coda_dentry_revalidate(struct dentry *de,=
 struct nameidata *nd)
>  	struct inode *inode;
>  	struct coda_inode_info *cii;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "coda_dentry_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> diff --git a/fs/hfs/sysdep.c b/fs/hfs/sysdep.c
> index 19cf291..b130d91 100644
> --- a/fs/hfs/sysdep.c
> +++ b/fs/hfs/sysdep.c
> @@ -18,6 +18,12 @@ static int hfs_revalidate_dentry(struct dentry *dentry=
, struct nameidata *nd)
>  	struct inode *inode;
>  	int diff;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "hfs_revalidate_dentry:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
> index 9c51f62..6580d1d 100644
> --- a/fs/ncpfs/dir.c
> +++ b/fs/ncpfs/dir.c
> @@ -302,6 +302,12 @@ ncp_lookup_validate(struct dentry *dentry, struct na=
meidata *nd)
>  	if (dentry =3D=3D dentry->d_sb->s_root)
>  		return 1;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "ncp_lookup_validate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b238d95..51b3d54 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1103,6 +1103,12 @@ static int nfs_lookup_revalidate(struct dentry *de=
ntry, struct nameidata *nd)
>  	struct nfs_fattr *fattr =3D NULL;
>  	int error;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "nfs_lookup_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> @@ -1508,6 +1514,12 @@ static int nfs_open_revalidate(struct dentry *dent=
ry, struct nameidata *nd)
>  	struct nfs_open_context *ctx;
>  	int openflags, ret =3D 0;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "nfs_open_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index 1a77dbe..20ef3ab 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -389,6 +389,11 @@ static const struct inode_operations proc_sys_dir_op=
erations =3D {
> =20
>  static int proc_sys_revalidate(struct dentry *dentry, struct nameidata *=
nd)
>  {
> +	if (!nd) {
> +		printk(KERN_ERR "proc_sys_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  	return !PROC_I(dentry->d_inode)->sysctl->unregistering;
> diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
> index ea9120a..6373450 100644
> --- a/fs/sysfs/dir.c
> +++ b/fs/sysfs/dir.c
> @@ -242,6 +242,12 @@ static int sysfs_dentry_revalidate(struct dentry *de=
ntry, struct nameidata *nd)
>  	struct sysfs_dirent *sd;
>  	int is_dir;
> =20
> +	if (!nd) {
> +		printk(KERN_ERR "sysfs_dentry_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> =20
> --=20
> 1.7.0.4
>=20
> ----------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCgAGBQJO1x9dAAoJENaSAD2qAscKYesP/1OOTAT0ZkXVAo5x7HZ3eIR6
Xg9zvtWQ12Qhlu4lBE56O6AIwIT8qdmMJ3s4HGetfX6AufCnpNF5QO9pDeNoI3hv
MyxHbg9+UdB5ZuCJuc6po00y6BRLZ366Prery2qwO3A+qlVKl8QDRxkRNvbzTX+7
FqhNHyoEFb5q70JP99COVwhkx9KRUL5bRoaD2szLvovwjgOykv664Tdmz/BmmreG
aXrbAwoByNbf4ZyvlcAkZDxBV/6qQCLj83FrOC0wp7zwPmmJYJeKLKBhrlN/PtuO
m/BkOY0KEgawbge93z+pe9sRZccFsVRmROnWXQrjKEHSLroQDOB4rbh+hqK62Dvb
tROWRuodOCGA9iagUGFc8cTREB66WEEmpuY7gzTpSVFaPTzOYAGqvJqrAA5W6/7J
IzPSK0d1bEpQc9rtJ+bLSmUyimoR1YUc0rO07vtQYwRNL17s975EoEsATPiDljsF
mvml+r1oLB+Tp3FYcn2O1tJI+c8whbDXCnlNcUV0AdonfMefgu05w4/SUdBH7uzg
u+pwoEU4l4r7jp8T0U1XWhYVCXYH0+dryew3UKqouyA4rh9aLnFnQVPxKEiF24SG
xdqPA8QpxiNdtAW4tqChJ5oTjh3aH3OPS+0ls+Qd0P8kVxuPUxvfO1KBr1f9uF2m
42NMP8YwgOHK5qGhlv7P
=Fu3x
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--
