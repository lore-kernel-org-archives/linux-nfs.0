Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35040 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726837AbeHOCjB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Aug 2018 22:39:01 -0400
From: NeilBrown <neilb@suse.com>
To: Bruce Fields <bfields@fieldses.org>
Date: Wed, 15 Aug 2018 09:49:19 +1000
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <20180814194334.GO7906@fieldses.org>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com> <20160321144349.GA12804@lst.de> <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com> <874lg3roua.fsf@notabene.neil.brown.name> <20180810170027.GF7906@fieldses.org> <20180810170312.GG7906@fieldses.org> <87d0uor11r.fsf@notabene.neil.brown.name> <20180812132100.GL7906@fieldses.org> <878t5bqgx0.fsf@notabene.neil.brown.name> <87ftzhb9rh.fsf@notabene.neil.brown.name> <20180814194334.GO7906@fieldses.org>
Message-ID: <871sb0bjb4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 14 2018, Bruce Fields wrote:

> On Tue, Aug 14, 2018 at 07:03:14PM +1000, NeilBrown wrote:
>> On Mon, Aug 13 2018, NeilBrown wrote:
>>=20
>> > On Sun, Aug 12 2018, Bruce Fields wrote:
>> >> OK, so not too important.  Still, it sounds like
>> >> inode_owner_or_capable() is something people expect to work for any
>> >> filesystem, so I wonder if there's a way to do that.  Or at least
>> >> disable it.
>> >
>> > We could add a new flag - MAY_OWN (or something) - to the flags
>> > recognised by inode_permission() and i_op->permission().
>> >
>> > If ->permission isn't set, inode_permission() uses
>> > inode_owner_or_capable().
>> > If it is, it gets to call that, or do whatever is appropriate.
>> >
>> > Is this flag the same as NFS_MAY_OWNER_OVERRIDE or not....??
>> >
>>=20
>> Pursuing this thought...
>>   NFSD_MAY_OWNER_OVERRIDE means "an operation is requested which
>>    may always be performed by the owner of the file, even if they
>>    don't have explicit permission via DAC setting."
>>=20
>> I think this is a reasonable description of how inode_owner_or_capable()
>> is used.  It is sometimes used on its own, where there is no permission
>> but that is relevant such as O_NOATIME or set_posix_acl(), or is used
>> as a precursor to and inode_permission() check, as in notify_change().
>>=20
>> The biggest difference is that NFSD_MAY_OWNER_OVERRIDE does have the
>> "or_capable".
>> As nfsd drops CAP_FOWNER, and the extra test won't hurt it.
>>=20
>> So I now think that a good solution to this problem would be to hoist
>> NFSD_MAY_OWNER_OVERRIDE into the VFS and change inode_permission() and
>> various i_op->permission functions to handle it.
>>=20
>> All we need is a good name....
>>   MAY_BY_OWNER  ???
>>   MAY_IF_OWNER
>>   MAY_BE_OWNER ???
>>=20
>> MAY_READ means "may I please read this file".  The flag needs to say
>> "may I act as the owner of this file", so
>>   MAY_ACT_AS_OWNER ????
>
> It's still a little different from the other permission bits in that I
> believe
>
> 	permission(., READ|WRITE)
> 		=3D=3D permission(., READ) && permission(., WRITE)
>
> but
>
> 	permission(., READ|OWNER_OVERRIDE)
> 		=3D=3D permission(., READ) || permission(., OWNER_OVERRIDE)
>

A little different from some other permission bits.
We have

#define MAY_EXEC		0x00000001
#define MAY_WRITE		0x00000002
#define MAY_READ		0x00000004
#define MAY_APPEND		0x00000008
#define MAY_ACCESS		0x00000010
#define MAY_OPEN		0x00000020
#define MAY_CHDIR		0x00000040
/* called from RCU mode, don't block */
#define MAY_NOT_BLOCK		0x00000080

MAY_CHDIR says something like "test the other bits, but first make sure
your cache is up-to-date".
MAY_NOT_BLOCK says "test the other bits, but not if you would need to
block.

MAY_OWNER would be "test the other bits, but only if not the owner".

So: not much more ad-hoc than other bits.

> ?
>
> Anyway, naming aside....  I don't know, sounds like it might work?
> Honestly I'm not completely sure I understand the proposal.

I guess I should supply a patch...

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAltzaoAACgkQOeye3VZi
gbmv6w/8CiyqlV6WnKq/Lq5Z5m9UvasUxsYfwjlQPI7wKB68Dq1BdiVK8TvduNbX
nL/f3lnwsD+axnSNKMauEtGSlZPtGX8QbIdYAEvfhkctvd5UnbTv2LhwLNRFWGjf
xjIVjUbLjyfbFCAaGYXMt9saFxM70g292m8jMzImginPdH4mE6bk9d12YdZJ8Lfb
TrAtmHwCNU7XX7ZFkiRz1FlJESOngCFvr1810xNEQ7qRkvoYqUB4/ljUrRCWpPTq
lCaRj3RAWcNhh2b1JzJQIz5bYsAg3NcTGkVU63MzI8t2BxE2ehK7SBfn+xXoGb1D
9qSdEa6B6OS6P5kLdvhDZS//YtybeOfz1vae3MUdEm9HRMMWmxtDV/eemqoJWhch
1PQHv2bgKNqdkeoh1UT66y8vaXSYOeBa5kq6fRKD29hx3EwJYQxyefzJ8CONKC9w
B3ORn0R9G7dWnKhWqUiAKa6ZvZ1w1SwvLu8PpYkvEPMKfCQ9q/ZiU60GQkX3JbcK
r9hNjBnEbxE2gIHjt+T9NX6miNgBjVl8xrX1umPG3V3OY+pS96q0cS1vT/9Hh5k6
oI5gbYiTmeu/54vloMRkO/apMQUdAB9ysl/2hXV9mD5D9Xls1DfzNh7ZCIVJW069
wq7jiCW1pKNTATrXzwuW8xX1Zjs93m1NuSfpJXU4t7Wiq5nG1FQ=
=JSfz
-----END PGP SIGNATURE-----
--=-=-=--
