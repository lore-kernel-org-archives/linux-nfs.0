Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55170 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751932AbdDKAkT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 20:40:19 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Tue, 11 Apr 2017 10:40:10 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v3 0/4] add systemd generator for the rpc_pipefs mountpoint
In-Reply-To: <20170406163104.28397-1-smayhew@redhat.com>
References: <20170406163104.28397-1-smayhew@redhat.com>
Message-ID: <87mvbnwzdh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Apr 06 2017, Scott Mayhew wrote:

> Changes since v2: retained the name "general" for the global section of
> the /etc/nfs.conf file.
>
> These patches aim to make it a little easier to change the mountpoint.
> Right now if you change the pipefs-directory in /etc/nfs.conf, you still
> need to manually override the dependencies in the systemd unit files in
> order for the change to actually work.
>
> The first patch moves rpc.idmapd's (mostly) undocumented
> pipefs-directory from /etc/idmapd.conf to /etc/nfs.conf.
>
> The second patch adds a deprecation warning to  rpc.gssd if it reads its
> pipefs-directory setting from the [gssd] section of /etc/nfs.conf
> instead of from the [general] section.
>
> The third patch allows blkmapd to read its pipefs-directory setting from
> the [general] section of /etc/nfs.conf as well (previously it was
> hard-coded).
>
> The final patch adds a systemd generator that reads the
> pipefs-directory configuration from /etc/nfs.conf, and if it differs
> from the default it will automatically create a systemd mount unit
> file for the pipefs mountpoint and it will override the dependencies on
> the pipefs mountpoint via the rpc_pipefs.target unit file.
>
> Scott Mayhew (4):
>   idmapd: move the pipefs-directory config option to nfs.conf
>   gssd: add a deprecation warning for pipefs-directory in gssd section
>   blkmapd:  allow the rpc_pipefs mountpoint to be overridden
>   systemd: add a generator for the rpc_pipefs mountpoint

Looks good.  Thanks for persisting with this!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljsJeoACgkQOeye3VZi
gbmqvRAAu4uzUTMCvc3ovaFQ7PIMiemTy/EWbUMtJGtu7fEB5lT848WHIXjdiqxz
bQtwB5fHb5JjtYasccbIh0qrn7LFL7kR8v5IbfjjoG4BOh6RdCJJ4VmI5wbEkz2q
pVjxcmfNCXTw+W+Rrtl7ntvTn01lAywPk8OL88sj/eIPAxx0pKqH+MfGgciEOLLX
d8sn68Mqcfd+JwvzlA0xE8/gFPpmWX6zIObKy6m9cCMGwO2xHMR6BaKnb9WLyBhL
hlUbo6WlTVn7k/gx23oIiLGDDfKAldU32PtcqKloyON0PgBp2wvc0Khqbkf1pi91
ayADzH/ajCJmX6Ds8mv/0a/UyW5isM57mF5nsDejR6dKLEjhiUlB4pTo2tYRSnHl
xRadvNXtoQlwMJ8rkkgFkT78e9DOf/O6y+wTqbGGH7WTzKeMgeZL6MSfS9E6efDY
Zb5vVmtGe7A/4qA3g9Ekc9uwWbYR0TJS69ZVKMiO28JYtoqEmB/N6qRK2nsmh2O5
/KOwYq+TtktALdLW0mhgfMJrdcUHHZz6x4n+QtN2cQHU1PZ+Fi4a5IFQvzkp84QX
CYu7CFYxEtrCz52V5LMuMgCkiGvvs1bM4cV9d02G1pS26miqbnOj62v48ZjA8DPa
aMc6fQW5JTDQSiRB08uYQwa5pPsim24f+98b+YrtkMcEsZGabwU=
=3SrJ
-----END PGP SIGNATURE-----
--=-=-=--
