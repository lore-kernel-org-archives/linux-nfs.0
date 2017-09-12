Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45232 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751151AbdILF3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Sep 2017 01:29:47 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton\@redhat.com" <jlayton@redhat.com>,
        "jlayton\@kernel.org" <jlayton@kernel.org>
Date: Tue, 12 Sep 2017 15:29:37 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
In-Reply-To: <1505183055.31542.2.camel@primarydata.com>
References: <20170720194227.7830-1-jlayton@kernel.org> <1503683981.22608.0.camel@redhat.com> <87h8wsiog4.fsf@notabene.neil.brown.name> <1503920855.4563.12.camel@redhat.com> <87pobfgo9q.fsf@notabene.neil.brown.name> <1504004058.4679.7.camel@redhat.com> <87efrjb2mn.fsf@notabene.neil.brown.name> <1504784132.4954.12.camel@redhat.com> <1504796087.3561.7.camel@primarydata.com> <874ls9diij.fsf@notabene.neil.brown.name> <1505183055.31542.2.camel@primarydata.com>
Message-ID: <87k214bi2m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Sep 12 2017, Trond Myklebust wrote:
>
> That makes sense to me. I'm applying and will send as an update to
> 4.14...
>

Thanks!
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm3cMEACgkQOeye3VZi
gbl2mw//UVzdj9Y27pRWj9S4RfhqXCQYbDzlInnv9GaWj/Xf7x6fcHNaSSr8Bu2S
1HsD2mkfMMqvm7uITJh5cWvkGTWX9mwMcj5GMnEnY+aV1zmIHivntqeYN+iuZtCV
WfF4ZWW50tV0ray0r69xaUjGbU5korp1Q9PWwLDcU84y6MeoP7WUVLwb/hZfa/k3
Y5h0LRHsf7Qk4c9bliiwLEyvxIUeP+6t3L5sq1V+1/qvAH4s+9QDQ+6mW1D8apBj
es9cQTh9f6REHmGNiX3IMGcGTcBuAXf2FY7a5kCsXR1gv0wMzd/OdFAUtP9evkKM
UB3LhEgm+BYIhUOubWi14stitqoUPX6wr9EWFi/cIXo6vcEccCOjhbXjeFgZ4fZR
wtNDXGxvvn25iTbERK5VR04ou5Xjrz5fuxxZjjSKT/GdMQGy3Uihu/v9nUZzT//I
cmOYOZtpjlHp8ryMkOz7/43KwKqlO3tRz5JrxTZ7hK7L9E7awon32vdNa9tmx4bv
LWybdLq2irolcRPhoPOqwyR9KZiNhaMnCfvDTtgWHXLvZr/bwLq7xYetSyvUC/J2
iBx0rYgHsH2gDdYEJRONNb83Hflk2Om+MWd7tB0YryhX36Cj2kXjKIZNt353jQIC
GoeJI7bHv1DaTBRDIrR7q8jcrtg27zzVDvTRm997mSklh4Bl+3g=
=4Jph
-----END PGP SIGNATURE-----
--=-=-=--
