Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:51269 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbaD1VcU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 17:32:20 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so3017870pad.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Apr 2014 14:32:19 -0700 (PDT)
Content-Type: multipart/signed; boundary="Apple-Mail=_9F20E3D4-0CB4-447A-955D-384C65C0341D"; protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH -V1 22/22] ext4: Add Ext4 compat richacl feature flag
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <1398615293-22931-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Mon, 28 Apr 2014 15:31:56 -0600
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <88FB2DB7-126A-400E-9B44-19E99A553B2B@dilger.ca>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1398615293-22931-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_9F20E3D4-0CB4-447A-955D-384C65C0341D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 27, 2014, at 10:14 AM, Aneesh Kumar K.V =
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> This feature flag can be used to enable richacl on
> the file system. Once enabled the "acl" mount option
> will enable richacl instead of posix acl

I was going to complain about this patch, because re-using the "acl"
mount option to specify richacl instead of POSIX ACL would be very
confusing, since older kernels used the "acl" mount option to enable
POSIX ACLs.

Looking closer, I see that "acl" and "noacl" just means enable or =
disable
the ACL functionality on the filesystem.  Please fix up the commit =
comment.

Some more comments inline.

> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index 6f9e6fadac04..2a0221652d79 100644
> --- a/fs/ext4/super.c
> +++ b/fs/ext4/super.c
> @@ -1274,6 +1274,30 @@ static ext4_fsblk_t get_sb_block(void **data)
> 	return sb_block;
> }
>=20
> +static void enable_acl(struct super_block *sb)
> +{
> +#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && =
!defined(CONFIG_EXT4_FS_RICHACL)
> +	return;
> +#endif
> +	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
> +		sb->s_flags |=3D MS_RICHACL;
> +		sb->s_flags &=3D ~MS_POSIXACL;
> +	} else {
> +		sb->s_flags |=3D MS_POSIXACL;
> +		sb->s_flags &=3D ~MS_RICHACL;
> +	}

This should put the #ifdef around the code that is being =
enabled/disabled,
otherwise it just becomes dead code:

static int enable_acl(struct super_block *sb)
{
	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
#if defined(CONFIG_EXT4_FS_RICHACL)
		sb->s_flags |=3D MS_RICHACL;
		sb->s_flags &=3D ~MS_POSIXACL;
#else
		return -EOPNOTSUPP;
#endif
	} else {
#if defined(CONFIG_EXT4_FS_POSIX_ACL)
		sb->s_flags |=3D MS_POSIXACL;
		sb->s_flags &=3D ~MS_RICHACL;
#else
		return -EOPNOTSUPP;
#endif
	}
	return 0;
}

> +
> +static void disable_acl(struct super_block *sb)
> +{
> +#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && =
!defined(CONFIG_EXT4_FS_RICHACL)
> +	return;
> +#endif
> +	sb->s_flags &=3D ~(MS_POSIXACL | MS_RICHACL);
> +	return;
> +}

"return" is not needed at the end of void functions. Same comment on =
#ifdef:

static void disable_acl(struct super_block *sb)
{
#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
	sb->s_flags &=3D ~(MS_POSIXACL | MS_RICHACL);
#endif
}


> +
> #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
> static char deprecated_msg[] =3D "Mount option \"%s\" will be removed =
by %s\n"
> 	"Contact linux-ext4@vger.kernel.org if you think we should keep =
it.\n";
> @@ -1417,9 +1441,9 @@ static const struct mount_opts {
> 	 MOPT_NO_EXT2 | MOPT_DATAJ},
> 	{Opt_user_xattr, EXT4_MOUNT_XATTR_USER, MOPT_SET},
> 	{Opt_nouser_xattr, EXT4_MOUNT_XATTR_USER, MOPT_CLEAR},
> -#ifdef CONFIG_EXT4_FS_POSIX_ACL
> -	{Opt_acl, EXT4_MOUNT_POSIX_ACL, MOPT_SET},
> -	{Opt_noacl, EXT4_MOUNT_POSIX_ACL, MOPT_CLEAR},
> +#if defined(CONFIG_EXT4_FS_POSIX_ACL) || =
defined(CONFIG_EXT4_FS_RICHACL)
> +	{Opt_acl, EXT4_MOUNT_ACL, MOPT_SET},
> +	{Opt_noacl, EXT4_MOUNT_ACL, MOPT_CLEAR},
> #else
> 	{Opt_acl, 0, MOPT_NOSUPPORT},
> 	{Opt_noacl, 0, MOPT_NOSUPPORT},
> @@ -3496,8 +3520,8 @@ static int ext4_fill_super(struct super_block =
*sb, void *data, int silent)
> 		set_opt(sb, NO_UID32);
> 	/* xattr user namespace & acls are now defaulted on */
> 	set_opt(sb, XATTR_USER);
> -#ifdef CONFIG_EXT4_FS_POSIX_ACL
> -	set_opt(sb, POSIX_ACL);
> +#if defined(CONFIG_EXT4_FS_POSIX_ACL) || =
defined(CONFIG_EXT4_FS_RICHACL)
> +	set_opt(sb, ACL);
> #endif
> 	if ((def_mount_opts & EXT4_DEFM_JMODE) =3D=3D =
EXT4_DEFM_JMODE_DATA)
> 		set_opt(sb, JOURNAL_DATA);
> @@ -3569,8 +3593,12 @@ static int ext4_fill_super(struct super_block =
*sb, void *data, int silent)
> 			clear_opt(sb, DELALLOC);
> 	}
>=20
> -	sb->s_flags =3D (sb->s_flags & ~MS_POSIXACL) |
> -		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
> +	/*
> +	 * clear ACL flags
> +	 */
> +	disable_acl(sb);

Is there any expectation that the flags would be set on a newly mounted
filesystem?

> +	if (test_opt(sb, ACL))
> +		enable_acl(sb);
>=20
> 	if (le32_to_cpu(es->s_rev_level) =3D=3D EXT4_GOOD_OLD_REV &&
> 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
> @@ -4844,8 +4872,9 @@ static int ext4_remount(struct super_block *sb, =
int *flags, char *data)
> 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
> 		ext4_abort(sb, "Abort forced by user");
>=20
> -	sb->s_flags =3D (sb->s_flags & ~MS_POSIXACL) |
> -		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
> +	disable_acl(sb);
> +	if (test_opt(sb, ACL))
> +		enable_acl(sb);

Similarly, it seems racy to me to disable ACL support and then re-enable
it here during remount, since that might cause some concurrent =
operations
to fail.  It seems like enable_acl() already handles clearing the flags
correctly, so something like the following would be better:

	if (test_opt(sb, ACL))
		enable_acl(sb);
	else
		disable_acl(sb);


Cheers, Andreas






--Apple-Mail=_9F20E3D4-0CB4-447A-955D-384C65C0341D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBU17IzHKl2rkXzB/gAQKXPRAAspLFy3dAIcBdo2QyptgRjobReaE7up9p
x5TuQ/hgJFyiJC/vxSpFXhrxBnJapU72CYRFVrS+Y/BncnPuGNjvMdJ8TMrnX1oJ
Rh+CXLGoJtD8YbO6UDeFWe0DLLRLCb+EdCOkxfKUyn2H7gmWYpnG+DwF17iB02r7
+QixtzgCgzqDLWPvaDn8IIYiJFgheQ1Wo0DLiIhX/0wqg+mB6DSVOHtZbRm51p7R
L5f1+Odkr2Xkf0G1v+1LRi+P79Ic4naqh4Z5LdcNw6uyxI0HiauSPWlfrsbatwA2
3YTUkWTb9bKElP1TX2AyerN/WcS+V/eD7nriaffG2GH4sIf24u1QsyaWP76+vCWO
3Zj2iNo6/1qHeIxqPxzopTSVIKiSDDCxGjpljuy2oXSSiYn7JH4U2u6DKUVwMS9s
15rIZsMHCtOOSytrKeQa1m8oD/FkI1mEaq1b5i9O1Mmikc8ur/82+WS6doM/oBvG
aykkJ2NMeE+t43L6+xATSG7j0P1kgmHXAhSocxXAKCCfmGt+CDUnv45JDXRDFAVR
D/sKllpY3zrQPiqSeStnlBTMM4xVkdc8BZRRg5CurlhT51Wdzt6WNMjRHwyZDB0x
NhrHxQmNCJwesaBP3om6mDLvo94USOgsbYU8/lUpn0Pc0K/mVmiC/ErGuv0odMUW
n1wOytQ3quk=
=p29Y
-----END PGP SIGNATURE-----

--Apple-Mail=_9F20E3D4-0CB4-447A-955D-384C65C0341D--
