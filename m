Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57843 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785AbcGSWuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 18:50:19 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 20 Jul 2016 08:50:12 +1000
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
In-Reply-To: <20160718200121.GC12304@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble> <20160714022643.5874.84409.stgit@noble> <20160718200121.GC12304@fieldses.org>
Message-ID: <878twx9ra3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 19 2016, J. Bruce Fields wrote:

> On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
>> I now think this was a mistaken idea.
>>=20
>> If a filesystem is exported with the "mountpoint" or "mp" option, it
>> should only be exported if the directory is a mount point.  The
>> intention is that if there is a problem with one filesystem on a
>> server, the others can still be exported, but clients won't
>> incorrectly see the empty directory on the parent when accessing the
>> missing filesystem, they will see clearly that the filesystem is
>> missing.
>>=20
>> It is easy to handle this correctly for NFSv3 MOUNT requests, but what
>> is the correct behavior if a client already has the filesystem mounted
>> and so has a filehandle?  Maybe the server rebooted and came back with
>> one device missing.  What should the client see?
>>=20
>> The "dev_missing" code tries to detect this case and causes the server
>> to respond with silence rather than ESTALE.  The idea was that the
>> client would retry and when (or if) the filesystem came back, service
>> would be transparently restored.
>>=20
>> The problem with this is that arbitrarily long delays are not what
>> people would expect, and can be quite annoying.  ESTALE, while
>> unpleasant, it at least easily understood.  A device disappearing is a
>> fairly significant event and hiding it doesn't really serve anyone.
>
> It could also be a filesystem disappearing because it failed to mount in
> time on a reboot.

I don't think "in time" is really an issue.  Boot sequencing should not
start nfsd until everything in /etc/fstab is mounted, has failed and the
failure has been deemed acceptable.
That is why nfs-server.services has "After=3D local-fs.target"

>
>> So: remove the code and allow ESTALE.
>
> I'm not completely sure I understand the justification.

"hangs are bad".

When you cannot get a reply from the NFS server there are multiple
possible causes from temporary network glitch to server-is-dead.
You cannot reliably differentiate, so you have to just wait.

There server itself doesn't have the same uncertainty about its exported
filesystems.  They are either working or they aren't.
So it is possible, and I think reasonable, to send a more definitive
reply - ESTALE.

This particularly became an issues with NFSv4.
With NFSv3, mounting the filesystem is distinct from accessing it.
So it was easy to fail a mount request but delay an access request.
With NFSv4 we don't have that distinction.  If we make accesses wait,
then we make mount attempts wait too, which isn't at all friendly.

>
> I don't like the current behavior either--I'd be happy if we could
> deprecate "mountpoint" entirely--but changing it now would seem to risk
> regressions if anyone depends on it.

True.  There isn't really an easy solution there.

"mountpoint" seemed like a good idea when I wrote it.  But I never got
any proper peer review.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXjq6kAAoJEDnsnt1WYoG5r0EP/2UclQl+0IFXAYpXsAajaaQV
/JyqPOvckjeWjlG0V++v07u0ejfph6auroTUj0q6FMq5U76vg83kN8AGUZRHkSiD
Vg0empOE/YBUYMuMyfsOx0DAcBNjQ/hznPuRiSzVzqUMVxp3egzSihQe2QfFJTWb
bX7aAgr5NRQxvJ1tn9NeR3JKHbPq5lBmBpJzXlo1BDFNQn4OjUmDfNn4rnIWeu0h
mFvYPKnQqky/xoyeEsffhOEpBSciXJ7AQg1BFylV6Wy3j54EGFHW4JI4UFpVmdLP
yQS6LuhJLYLyPUTLNfyF5ZV8tgaQdgRLlPqmZBLEKqr+Zq2rMbmPadDxBlyvbZEb
5Ow8F6Fva59O2/oX2wKN8+cb3H1cgNInaR2pSMfHvxuiXOm/wfn6LeI6kzBRI9we
BAshyfSsJcque9F1c28wHw4pCfW6xe5uRmW1e+lGondyqevZk1+zIkbrHG5NKelX
xN9erRBJ3tPUKfAAsEiKfNRhYiGUzmeM4zTnUzdlr110YvAI+wPKO/O7IRZVDT/Q
Cjk8VKqanRAVYMfDLljeXYQMf7DtyDaq38LLZjbPy2WbfXrwNEEXVDdvPNF9EQpi
aESSgYdlRAKlvwXOqMcU7xXfqeSuu1Q6dmFhVkj6z6z5HfkrjRlDtvcD+0jKNrqx
Rn28OXInNr2L9xtQ3KX4
=9eQZ
-----END PGP SIGNATURE-----
--=-=-=--
