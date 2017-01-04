Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38326 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937337AbdADVPM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 16:15:12 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, andros@netapp.com
Date: Thu, 05 Jan 2017 08:14:48 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 4] SVCAUTH reap the rsc cache entry on RPC_SS_PROC_DESTROY
In-Reply-To: <20170104202634.GA21562@fieldses.org>
References: <1482428286-33744-1-git-send-email-andros@netapp.com> <1482428286-33744-2-git-send-email-andros@netapp.com> <20170104202634.GA21562@fieldses.org>
Message-ID: <8737gymss7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 05 2017, J. Bruce Fields wrote:

> I'm not against the patch, but I'm still not convinced by the
> explanation:
>
> On Thu, Dec 22, 2016 at 12:38:06PM -0500, andros@netapp.com wrote:
>> From: Neil Brown <neilb@suse.com>
>>=20
>> The rsc cache code operates in a read_lock/write_lock environment.
>> Changes to a cache entry should use the provided rsc_update
>> routine which takes the write_lock.
>
> It looks pretty suspicious to be setting CACHE_NEGATIVE without the
> cache_lock for write, but I'm not actually convinced there's a bug there
> either.  In any case not one that you'd be hitting reliably.
>
>> The current code sets the expiry_time and the CACHE_NEGATIVE flag
>> without taking the write_lock as it does not call rsc_update.
>> Without this patch, while cache_clean sees the entries to be
>> removed, it does not remove the rsc_entries. This is because
>> rsc_update updates other fields such as flush_time and last_refresh
>> in the entry to trigger cache_clean to reap the entry.
>
> I think the root cause of the particular behavior you were seeing was
> actually an oversight from Neil's c5b29f885afe "sunrpc: use seconds
> since boot in expiry cache", which missed this one occurrence of
> get_seconds().  So it's setting the item's entry to something decades in
> the future.
>
> And that's probably not been a huge deal since these entries aren't so
> big, and they will eventually get cleaned up by cache_purge when the
> cache is destroyed.  Still, I can imagine it slowing down cache lookups
> on a long-lived server.
>
> The one-liner:
>
>  -		rsci->h.expiry_time =3D get_seconds();
>  +		rsci->h.expiry_time =3D seconds_since_boot();
>
> would probably also do the job.  Am I missing something?

I was missing that get_seconds() bug - thanks.
The other real bug is that setting h.expiry_time backwards should
really set cd->nextcheck backwards too.  I thought I had found code
which did that, but I think I was confusing ->nextcheck with ->flush_time.

>
> But, OK, I think Neil's patch will ensure entries get cleaned up more
> quickly than that would, and might also fix a rare race.

Yes.  The patch doesn't just fix the bug, whatever it is.  It provides a
proper interface for functionality that wasn't previously supported, and
so had been hacked into place.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhtZcgACgkQOeye3VZi
gbmWsBAAi+DFk1k7G8QuEzgXUqlOs8kBQta8nvAcG1Hw6Q4ZZ4NTpvqvFD38hK7r
O2NyGD0bZyRlHMBaEQeJeJULjAzHUidO+atDLKWlGaBhUPlplJTGOVOqiSiDfvx+
i3G2YqSLDwO2Y4ahccTAQUiNuWz044bPLtXre8qxTeGY/ktnx38AtLwnZxK7QtcS
2JSWFqnmANbtNhrdX5PpYhPiCkPmIzp0uCk6GpqYNSHbREezwBXB2ohwiTC9wkKW
swPN5AV1pDZcNp3dq61spJ9o3ZC/iOhx4mtLgq9YkYyYzUy7sj0SrkDXimV/k1Tv
dmy8KIyAqqIhbCbwcVtkZ7OD/Nhu105cT7bQ00oRTqDrSM1duy81dRIsYFg/R4Zk
vwz1yGVQury5qpzDeXpdYR9M0w1z0yJB7sjarzx4OekSajVLAw6f019D9bEhladC
g2hEcxBVPuDrFf1TFU7mySVVToafdbUa3rk8IMN/8sKwlrBHrcMOXCVe+TELZTDl
I3kol5eDmcKMEjHdmqvSHjWfkyggexZ/ECgplH6TBzBviYMXR9fdbDKDtakH4pLz
kpkVGt0nN/FC0yH0qMcFAj17rz1mViRLkZuYutneUeVMnpGcBpNe33TLn4R64v+O
y+7+Hgx3G9B4KSmaxTEmFQbcwWjjTSATKPRJOyZ5RW1NH+pF7Zg=
=SzcF
-----END PGP SIGNATURE-----
--=-=-=--
