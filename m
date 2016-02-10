Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43729 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755235AbcBJBpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2016 20:45:47 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 10 Feb 2016 12:45:37 +1100
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: restore fair scheduling to priority queues.
In-Reply-To: <87mvr9xsrn.fsf@notabene.neil.brown.name>
References: <87twnjb7lq.fsf@notabene.neil.brown.name> <CAHQdGtSbawsf+=uqz3D5UAPntHVKFnUgVZAYh3ym_Fs_+fHAoQ@mail.gmail.com> <874mfjay1l.fsf@notabene.neil.brown.name> <CAHQdGtTekchy7+6phSJikhPYk_FW4G6fuFEHy8WPn_t2iRUvEA@mail.gmail.com> <87mvr9xsrn.fsf@notabene.neil.brown.name>
Message-ID: <87k2mdxrr2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Feb 10 2016, NeilBrown wrote:

> On Sun, Dec 27 2015, Trond Myklebust wrote:
>
>> On Tue, Dec 15, 2015 at 10:10 PM, NeilBrown <neilb@suse.com> wrote:
>>> If you treated all reads and writed the same, then I can't see value in
>>> restoring fair scheduling.   If there is any difference, then I suspect
>>> we do need the fairness.
>>
>> I disagree. Reclaiming memory should always be able to pre-empt
>> "interactive" features such as read. Everything goes down the toilet
>> when we force the kernel into situations where it needs to swap.
>
> That's your call I guess.  I certainly agree that memory-reclaim writes
> should get some priority (e.g. two writes serviced for every read).
> Whether they should be allowed to completely block reads I'm less sure
> of.  But it is probably purely academic as if the system is busy
> reclaiming you are unlikely to have any reads to want to send.
>
> My problem would be solved (I think) by treating reads and non-reclaim
> writes as equals.  I'll make a patch, see if I can test it, and let you
> know.

ahh.... I just discovered
Commit: b0ac1bd2bbfd ("NFS: Background flush should not be low priority")

I didn't notice that before.  I suspect that will fix the problem -
thanks.

I'll try testing and let you know if there is a problem.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWupZCAAoJEDnsnt1WYoG5HmwQAL6n2u6AzzGxw5J2mvHw5zJb
FeTttXNsSb3NYHJyuqON8oE3vy0AgZ79w07XdNidRhMMxOj4Ecy+t3SVAteiIj+e
xddt8gSsrhk9nzXrzEzwh7LG1VnDuANdeupowBzW8673P2kuDLnnJ8UIi6yZoZRA
bPwJ8c0D3jWlPQtwUI55EmSO9pM3ILvikJB8K2WK22BzG7eDH6Z69ZCd+ybmCi59
DJ5HDCTcmQKD+z99/CkL+ArZzPJ9I4+4jn5lYqvP7qkzQOvNCno+QatzRE2U6zBo
pM2h3Aey3C0lfjp/By3IAzQvvXRymHTxmX7K6uiv665iQGMLtzG/Tc3XYqtUleyP
DKvb8hB+vjV4L/rZ/n7vv4Rw1JqNev7qAH99G4K3Snit4H26gy+zT9fdIEg0UW12
6Qt5KBomK6M5EEBkgmU3dzPsgf6pTwaFVAKr+Wxf61YEJ/50e2u39zJkEhm4QBVj
kN1Oxt/JheLMP1ZX0voJey0xTaMIwIhnHujOGV1AugPutHICOGI/kVa5ryp5pYUX
GAmHFstURBipmbjII1Qew3q06TV5ib7JChE+C9PG9xJshPWSwOyUXeBM8lqE3V5q
ZfA/bODQgX//o+BMVmM3AHpscPVATee+IkdR5HHzSNdvb5slyURubyV1y7r7s4zS
LeU+ct0aahGboTgeLsHo
=WiTH
-----END PGP SIGNATURE-----
--=-=-=--
