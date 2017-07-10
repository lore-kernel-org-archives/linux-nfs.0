Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37074 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754020AbdGJW45 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 18:56:57 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>
Date: Tue, 11 Jul 2017 08:56:44 +1000
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <8403677d-cb85-41b2-3c9c-179b82928b80@RedHat.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login> <87tw43fgrf.fsf@notabene.neil.brown.name> <87zicjyhby.fsf@notabene.neil.brown.name> <8403677d-cb85-41b2-3c9c-179b82928b80@RedHat.com>
Message-ID: <877ezf6gur.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 10 2017, Steve Dickson wrote:

> Hey Neil,
>
> On 07/04/2017 06:20 PM, NeilBrown wrote:
>> On Tue, May 30 2017, NeilBrown wrote:
>>=20
>>> Systemd does not, and will not, support "bg" correctly.
>>> It has other, better, ways to handle "background" mounting.
>>=20
>> For those who aren't closely watching systemd development, a
>> patch was recently accepted which causes systemd to work correctly with
>> NFS bg mounts.  So the above "and will not" was, happily, not correct.
> Could you please post a pointer to the thread?

The main commmit is
 https://github.com/systemd/systemd/commit/65e1dee7dcf1668c25c32f0238c93570=
8dbffbcf

The link in the title leads to
  https://github.com/systemd/systemd/pull/6103
which is the discussion of the pull request.
The "Fixes" link at the bottom leads to
 https://github.com/systemd/systemd/issues/6046
which is an 'issue' that started out as "we should warn if 'bg' is used"
but became "here is a fix so bg works".

I've been wondering if we should add text to nfs.5 suggesting that
automount is often a good match for NFS, and can particularly be useful
where "bg" is currently used.  Not sure what to do about timeouts
though.
systemd currently waits for the mount command to fail, or kills it after
90 seconds.  It doesn't return an error to accesses of the mount point
(typically ENODEV) until mount exits.  I think I would prefer a shorter
timeout before the error, but a longer timeout before killing mount.
But I'm not really sure.  Does anyone have opinions?

Thanks,
NeilBrown



--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllkBi4ACgkQOeye3VZi
gblf2hAAkGgsx+IID8uc2bypBZh24iFd0TlNnqkz9xPc/gr8GHSCrCg43XGocecv
65satFGyvluo9ErHgnG+q6vRRM3mYWQBqzh8ssp9CTk8/4KUl991/yGhzhZ3FoNz
xad3vHR4sb+ti/CJGtFHbnTwWryhOdKzr822BImtErxvQM/fVHLplltN/pYu6zq1
p3cYeQqNizFDVhGxJIACGEqBADUjVXKyDQY3Tms3kRen0T82mfVBYW0btH2zEWet
RKMkErEesC2xD7FZzNX56yxvEu0h0ajS3C9xqI7H7Rmbx4ieHYkkO7dPwFjVEds2
a5G+uFpfiuFAoA9Hb5aHJUeBCptYOOT+hAILoL+Z/HczMapVQ8lpUBpcQfLQi5+O
nQ3ChUKeXIYFVFECinFAv6599zyyRgsBnVB91W7FkVAPfGl8UlH6vl+qx16esoGq
II2iMNnjFmdlkTMDbgdHQSq5M6a8KACBlu7dR8Ai7ZiGl1xeqk35sLvfbSJF4lCd
raQaVtya8PXvNPmIfNmnCQdcovyJUbslgWs/UV996RBDQh2E0CoCH+kTDCxhNetF
Jw3c27KDWsNJBc2rWxA3Tnd570yqWvkn42NldRaAArtNYIkZ8lQn2k7nS0uPWSMq
6rFw4cVm1I7liUQht086altDlzWHUot/ZyDqce81ItrsTekTi9Y=
=1eb4
-----END PGP SIGNATURE-----
--=-=-=--
