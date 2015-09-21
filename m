Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33741 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbIUN7M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 09:59:12 -0400
Subject: Re: [RFC v7 13/41] richacl: Check if an acl is equivalent to a file
 mode
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
 <1441448856-13478-14-git-send-email-agruenba@redhat.com>
 <20150917182219.GB13825@fieldses.org> <20150918005607.GB16699@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <56000D2B.6000705@gmail.com>
Date: Mon, 21 Sep 2015 09:59:07 -0400
MIME-Version: 1.0
In-Reply-To: <20150918005607.GB16699@fieldses.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms090601060905010007050009"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms090601060905010007050009
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-09-17 20:56, J. Bruce Fields wrote:
> On Thu, Sep 17, 2015 at 02:22:19PM -0400, bfields wrote:
>> On Sat, Sep 05, 2015 at 12:27:08PM +0200, Andreas Gruenbacher wrote:
>>> ACLs are considered equivalent to file modes if they only consist of
>>> owner@, group@, and everyone@ entries, the owner@ permissions do not
>>> depend on whether the owner is a member in the owning group, and no
>>> inheritance flags are set.  This test is used to avoid storing richac=
ls
>>> if the acl can be computed from the file permission bits.
>>
>> We're assuming here that it's OK for us to silently rearrange an ACL a=
s
>> long as the result is still equivalent (in the sense that the permissi=
on
>> algorithm would always produce the same result).
>>
>> I guess that's OK by me, but it might violate user expectations in som=
e
>> simple common cases, so may be worth mentioning in documentation
>> someplace if we don't already.
>
> Also your notion of mode-equivalence here is interesting, it's actually=

> a strict subset of the ACLs that produce the same permission results as=

> a mode.  (For example, everyone:rwx,bfields:rwx is equivalent to 0777
> but won't be considered mode-equivalent by this algorithm.)
Although it could also be equivalent to 0707, or (if bfields is the=20
group name also) 0077, or even (if bfields isn't the group or owner of=20
the file) 0007.  Mode equivalence get's even trickier when you throw in=20
permissions just beyond rwx (for example, by Windows standards, the=20
usage of the execute bit on directories is weird (they have a separate=20
permission in their ACE's for directory listing), or by VMS standards,=20
write permission on a directory doesn't mean that you can delete things=20
in it (VMS actually had a separate bit for the delete permission, and=20
even had separate permissions for system access)).
>
> I think the choices you've made probably make the most sense, they just=

> wouldn't have been obvious to me.  Anyway, so, OK by me:
>
> 	Reviewed-by: J. Bruce Fields <bfields@redhat.com>
>
> --b.
>
>>
>> --b.
>>
>>>
>>> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
>>> ---
>>>   fs/richacl_base.c       | 104 +++++++++++++++++++++++++++++++++++++=
+++++++++++
>>>   include/linux/richacl.h |   1 +
>>>   2 files changed, 105 insertions(+)
>>>
>>> diff --git a/fs/richacl_base.c b/fs/richacl_base.c
>>> index 3163152..106e988 100644
>>> --- a/fs/richacl_base.c
>>> +++ b/fs/richacl_base.c
>>> @@ -379,3 +379,107 @@ richacl_chmod(struct richacl *acl, mode_t mode)=

>>>   	return clone;
>>>   }
>>>   EXPORT_SYMBOL_GPL(richacl_chmod);
>>> +
>>> +/**
>>> + * richacl_equiv_mode  -  compute the mode equivalent of @acl
>>> + *
>>> + * An acl is considered equivalent to a file mode if it only consist=
s of
>>> + * owner@, group@, and everyone@ entries and the owner@ permissions =
do not
>>> + * depend on whether the owner is a member in the owning group.
>>> + */
>>> +int
>>> +richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
>>> +{
>>> +	mode_t mode =3D *mode_p;
>>> +
>>> +	/*
>>> +	 * The RICHACE_DELETE_CHILD flag is meaningless for non-directories=
, so
>>> +	 * we ignore it.
>>> +	 */
>>> +	unsigned int x =3D S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
>>> +	struct {
>>> +		unsigned int allowed;
>>> +		unsigned int defined;  /* allowed or denied */
>>> +	} owner =3D {
>>> +		.defined =3D RICHACE_POSIX_ALWAYS_ALLOWED |
>>> +			   RICHACE_POSIX_OWNER_ALLOWED  | x,
>>> +	}, group =3D {
>>> +		.defined =3D RICHACE_POSIX_ALWAYS_ALLOWED | x,
>>> +	}, everyone =3D {
>>> +		.defined =3D RICHACE_POSIX_ALWAYS_ALLOWED | x,
>>> +	};
>>> +	const struct richace *ace;
>>> +
>>> +	if (acl->a_flags & ~(RICHACL_WRITE_THROUGH | RICHACL_MASKED))
>>> +		return -1;
>>> +
>>> +	richacl_for_each_entry(ace, acl) {
>>> +		if (ace->e_flags & ~RICHACE_SPECIAL_WHO)
>>> +			return -1;
>>> +
>>> +		if (richace_is_owner(ace) || richace_is_everyone(ace)) {
>>> +			x =3D ace->e_mask & ~owner.defined;
>>> +			if (richace_is_allow(ace)) {
>>> +				unsigned int group_denied =3D
>>> +					group.defined & ~group.allowed;
>>> +
>>> +				if (x & group_denied)
>>> +					return -1;
>>> +				owner.allowed |=3D x;
>>> +			} else /* if (richace_is_deny(ace)) */ {
>>> +				if (x & group.allowed)
>>> +					return -1;
>>> +			}
>>> +			owner.defined |=3D x;
>>> +
>>> +			if (richace_is_everyone(ace)) {
>>> +				x =3D ace->e_mask;
>>> +				if (richace_is_allow(ace)) {
>>> +					group.allowed |=3D
>>> +						x & ~group.defined;
>>> +					everyone.allowed |=3D
>>> +						x & ~everyone.defined;
>>> +				}
>>> +				group.defined |=3D x;
>>> +				everyone.defined |=3D x;
>>> +			}
>>> +		} else if (richace_is_group(ace)) {
>>> +			x =3D ace->e_mask & ~group.defined;
>>> +			if (richace_is_allow(ace))
>>> +				group.allowed |=3D x;
>>> +			group.defined |=3D x;
>>> +		} else
>>> +			return -1;
>>> +	}
>>> +
>>> +	if (group.allowed & ~owner.defined)
>>> +		return -1;
>>> +
>>> +	if (acl->a_flags & RICHACL_MASKED) {
>>> +		if (acl->a_flags & RICHACL_WRITE_THROUGH) {
>>> +			owner.allowed =3D acl->a_owner_mask;
>>> +			everyone.allowed =3D acl->a_other_mask;
>>> +		} else {
>>> +			owner.allowed &=3D acl->a_owner_mask;
>>> +			everyone.allowed &=3D acl->a_other_mask;
>>> +		}
>>> +		group.allowed &=3D acl->a_group_mask;
>>> +	}
>>> +
>>> +	mode =3D (mode & ~S_IRWXUGO) |
>>> +	       (richacl_mask_to_mode(owner.allowed) << 6) |
>>> +	       (richacl_mask_to_mode(group.allowed) << 3) |
>>> +		richacl_mask_to_mode(everyone.allowed);
>>> +
>>> +	/* Mask flags we can ignore */
>>> +	x =3D S_ISDIR(mode) ? 0 : RICHACE_DELETE_CHILD;
>>> +
>>> +	if (((richacl_mode_to_mask(mode >> 6) ^ owner.allowed)    & ~x) ||
>>> +	    ((richacl_mode_to_mask(mode >> 3) ^ group.allowed)    & ~x) ||
>>> +	    ((richacl_mode_to_mask(mode)      ^ everyone.allowed) & ~x))
>>> +		return -1;
>>> +
>>> +	*mode_p =3D mode;
>>> +	return 0;
>>> +}
>>> +EXPORT_SYMBOL_GPL(richacl_equiv_mode);
>>> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
>>> index d4a576c..6535ce5 100644
>>> --- a/include/linux/richacl.h
>>> +++ b/include/linux/richacl.h
>>> @@ -304,6 +304,7 @@ extern unsigned int richacl_mode_to_mask(mode_t);=

>>>   extern unsigned int richacl_want_to_mask(unsigned int);
>>>   extern void richacl_compute_max_masks(struct richacl *);
>>>   extern struct richacl *richacl_chmod(struct richacl *, mode_t);
>>> +extern int richacl_equiv_mode(const struct richacl *, mode_t *);
>>>
>>>   /* richacl_inode.c */
>>>   extern int richacl_permission(struct inode *, const struct richacl =
*, int);
>>> --
>>> 2.4.3
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



--------------ms090601060905010007050009
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwOTIxMTM1OTA3WjBPBgkq
hkiG9w0BCQQxQgRAW/B3ajXgyRvnFT4kmSND5dcq10iKWoBupezWoaca57Gd3ANUeVpmDGMO
Jyg2EHMdDiyJd2sVVJVnTZmGmnsuYDBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxEt+DCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxEt+DAN
BgkqhkiG9w0BAQEFAASCAgB4UZT3nGdIAHuREprTLmRHK47TI0JMk52aVWj2pb6r1t0j8QCP
3EQ5WBLIFIWteshEFDy4Ao32NlOLCEg2y+vyisgg8zHS/p39Ac2qw6SXN6CXEcXk5KxarmeX
h0lO9ww6TKU9n8ORmJCbD+Wv7ztwzoEL6celBNTZ/sc2kN8l2rk0/aDVpGJav6xYS5erx66K
BYdUqlJtjEIlI5JaCCCynYDzLx6VGmA3mz/3i00KZ/XxxJWTN6ux5U5+yfbXXPUXL1cbO7Uf
C0SGEkjD+Xd/4jmwM/HoDkAZE5HXYn1rth7KG4cpqebE5XBM81M7RQb9bM7Q+yp/kXFlgZ6k
tVay4FWyixTWKCCjyFDmWY0UfneNQltHyTCVxHNjNC6UO1mpRoz28N41VGkyzq4E4Jxmkkc+
OBlaHR0A+GV1Yvq8xrncDIt1RMdZ4+t6gisBQG80FG+DbfMbnYdOEGy0w2wXMZX+6EuejyCr
UI5HUXIpRUwrFJfxa1+etLE4HmiwABu2pFXQz5gFb3qtC4hO2JaLR/m+iAPdGnuLGtPt2s45
16Ko8dBsyhXK4+uQhCm9yeggjNH2BzCWIdDaqqvWodOPBtxvuwoIBQLB1JiEAlQA8C5JwXe1
t3C0IKB46/VNBJ8B7HCH+TFT8p0oCDLHTAqXPGGQHnP/hvStUkDWm2Q8dgAAAAAAAA==
--------------ms090601060905010007050009--
