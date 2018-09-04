Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49124 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726520AbeIEDOn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Sep 2018 23:14:43 -0400
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 91FD0AE62
        for <linux-nfs@vger.kernel.org>; Tue,  4 Sep 2018 22:47:28 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 05 Sep 2018 08:47:23 +1000
Subject: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
Message-ID: <87r2i8vq10.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


With NFSv4.1, the server specifies max_rqst_sz and max_resp_sz in the
reply to CREATE session.

If the client finds it needs to call nfs4_reset_session(), it might get
smaller sizes back, so any pending read/writes would need to be resized.

However, I cannot see how the retry handling for reads/writes has any
chance to change the size.  It looks like a request is broken up to
match the original ->rsize and ->wsize, then those individual IO
requests can be retried, but the higher level request is never
re-evaluated in light of a new size.

Am I missing something, or is this not supported at present?
If it isn't supported, any suggestions on how best to handle a
reduction of the rsize/wsize ??

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAluPC3sACgkQOeye3VZi
gbm8tQ//USYuxvAIIGthdqoMurnk6cA5QAY9FVg4pBlxku6p6j5PEYsPuEEvbf0s
fpKNZRtYe6Ewv4kvNHwysAHyB6WKdLEfx15/KRZpAnIok/tvRcGmSzW7pfGg3ML9
TynKq+mhdF8sX7lzlye4XgwOWvaAfR6BO5WjUI4CKqhTnhECF5GLXyXXB7drNXJQ
99NQu+9bRwgBG8uiRVbha6pwHI7C4cNBZvpuCx02TLDB9IFegojle7NGJQjQLT9q
L4dZChe5GD0DyYiybGoYKqh5+Rz+JOlWn/JeK6O2YmSH1dKWYLwghPikoclOt5aE
cigREnEdSnF2YkTyzDFnlVhw54YiP9ztg2Y0I5UnFgQlI9zidtFGvIkKthQLA7AX
cHLbAIRj3Jqi/G7wTSVYlDDAA2kVQl6M2VDHEH6BNd8pM9IzEEKAkLGTSL6DJCls
4s6xV9E1iwT+kYwFYzbMn20tmTCM4/Qfr057RJysy3bNjliqO1a/H/clqkFc8joZ
rXp0NMGSR40HO8LcB8+NXI0ZoL3ikvlMnhXBti/ZV4VTWe0fperope7rH6V4vi8J
2PmtOA9RVTNjfbtBbyAh10gITrDdJk3pYi5Vn1+86UAuRUXUAO0U5qVzXnG+3Ato
Vu9QxGGreVhQaY5/VjhVB4YgBw2HBl+9bToIGGrhWz7H9vPDuME=
=f6RP
-----END PGP SIGNATURE-----
--=-=-=--
