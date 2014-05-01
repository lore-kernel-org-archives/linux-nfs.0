Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54812 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbaEARxc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 13:53:32 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so3913460pad.34
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 10:53:31 -0700 (PDT)
Content-Type: multipart/signed; boundary="Apple-Mail=_4DBC8F08-F27A-4B21-841E-61525D6DE9B7"; protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH -V1 22/22] ext4: Add Ext4 compat richacl feature flag
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <877g65biu4.fsf@linux.vnet.ibm.com>
Date: Thu, 1 May 2014 11:52:48 -0600
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <14876338-8D87-48CD-B8B9-B44F311BB329@dilger.ca>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1398615293-22931-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <88FB2DB7-126A-400E-9B44-19E99A553B2B@dilger.ca> <877g65biu4.fsf@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_4DBC8F08-F27A-4B21-841E-61525D6DE9B7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On May 1, 2014, at 9:48 AM, Aneesh Kumar K.V =
<aneesh.kumar@linux.vnet.ibm.com> wrote:

> Andreas Dilger <adilger@dilger.ca> writes:
>=20
>> On Apr 27, 2014, at 10:14 AM, Aneesh Kumar K.V =
<aneesh.kumar@linux.vnet.ibm.com> wrote:
>>> This feature flag can be used to enable richacl on
>>> the file system. Once enabled the "acl" mount option
>>> will enable richacl instead of posix acl
>>=20
>>> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
>>> index 6f9e6fadac04..2a0221652d79 100644
>>> --- a/fs/ext4/super.c
>>> +++ b/fs/ext4/super.c
>>> @@ -1274,6 +1274,30 @@ static ext4_fsblk_t get_sb_block(void **data)
>>> 	return sb_block;
>>> }
>>>=20
>>> +static void enable_acl(struct super_block *sb)
>>> +{
>>> +#if !defined(CONFIG_EXT4_FS_POSIX_ACL) && =
!defined(CONFIG_EXT4_FS_RICHACL)
>>> +	return;
>>> +#endif
>>> +	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
>>> +		sb->s_flags |=3D MS_RICHACL;
>>> +		sb->s_flags &=3D ~MS_POSIXACL;
>>> +	} else {
>>> +		sb->s_flags |=3D MS_POSIXACL;
>>> +		sb->s_flags &=3D ~MS_RICHACL;
>>> +	}
>>=20
>> This should put the #ifdef around the code that is being =
enabled/disabled,
>> otherwise it just becomes dead code:
>>=20
>> static int enable_acl(struct super_block *sb)
>> {
>> 	if (EXT4_HAS_COMPAT_FEATURE(sb, EXT4_FEATURE_COMPAT_RICHACL)) {
>> #if defined(CONFIG_EXT4_FS_RICHACL)
>> 		sb->s_flags |=3D MS_RICHACL;
>> 		sb->s_flags &=3D ~MS_POSIXACL;
>> #else
>> 		return -EOPNOTSUPP;
>> #endif
>> 	} else {
>> #if defined(CONFIG_EXT4_FS_POSIX_ACL)
>> 		sb->s_flags |=3D MS_POSIXACL;
>> 		sb->s_flags &=3D ~MS_RICHACL;
>> #else
>> 		return -EOPNOTSUPP;
>> #endif
>> 	}
>> 	return 0;
>> }
>=20
> That is too much #ifdef with no real benefit ?

The benefit is that if neither CONFIG_EXT4_FS_RICHACL nor =
CONFIG_EXT4_FS_POSIX_ACL are defined there isn't unreachable code
after "return" at the start of the function.  Some static code
analysis tools will complain about this.

Cheers, Andreas






--Apple-Mail=_4DBC8F08-F27A-4B21-841E-61525D6DE9B7
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBU2KJ8XKl2rkXzB/gAQJVtg/8DahNWsnhNP8WqPHC2W3IExVCQkBn838r
FlbvVYdLFbgpJwgXqi3gKW7mwcMJCIm1xIP9spYepYMHqDtNkdZloKbi+jz5HcK/
T9Z/5TPsxwlLYh9y6w0MU9dR5QVPxKCEyRow4Frm8geGXeyWEFGwFVDXh9eJkRjd
DBJRiosJUYycl776nF6+nrgYAuKbomSVm2gEYiYL7CrhXT2bfyjKFi8ocBPXTKXl
UptXawH2cQa933Vesb9EvNv56IYmjnUpPA9gVBTOt9rAYvxf8Fgf+lbVe+/01Ec4
q/ulu3RyyVkqZIxKvyKnQ1dKq5m98JpDJ9gf1edwReq7hcJ6fBZDhFEo6s6zXOPR
v2Vxa6QmUnj4QC23JPbTaEgyr8JWSCgZimX2ry0GR6JhMO/a+60njg/+iiHNysZh
9eTktCYyqm/r4oydKIS90wq2TNXRJb9AQpFfG3d3nmCeiyNyr/WPPvkDCcqmHLKs
Ki2HgzbDmWps9GIABMV/lNs3XTQylnqc7E+45GRoJRX2KJkP6kehiTg3eK9ZXehG
W/b1dcTrIIN3XDjknh+q2m3B3lCOt8hVUMVjJTHJNYCa7YkBc6QESDX9oDAqqe/L
hWFoJseb2L6XlauDmNxhY5RAGjWdH3IzAow38soiiwaZI3pnrVwWH+CO+WflO08F
s9P+0JpDPIQ=
=PLXn
-----END PGP SIGNATURE-----

--Apple-Mail=_4DBC8F08-F27A-4B21-841E-61525D6DE9B7--
