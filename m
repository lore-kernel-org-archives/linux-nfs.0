Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42798 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752521AbcLFWrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 17:47:37 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 07 Dec 2016 09:47:29 +1100
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove nfs-config.service
In-Reply-To: <20161206172641.GA31197@fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble> <20161206172641.GA31197@fieldses.org>
Message-ID: <87lgvs4qv2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07 2016, J. Bruce Fields wrote:

> On Fri, Dec 02, 2016 at 02:58:27PM +1100, NeilBrown wrote:
>> This is an RFC series.  A little voice at the back of my head keeps
>> telling me that I'm over-engineering, but there isn't really that much
>> new code, and I think the result has a lot to recommend it.
>>=20
>> But please tell me if I'm wrong.
>>=20
>> - Various daemons (not all) are enhance to accept configuration
>>   information from /etc/nfs.conf
>> - the conffile reader is enhanced to support include files, and
>>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>>   files usefully
>
> Currently those files are actually sourced by a shell, right?  So in
> theory people could be doing tricky things in there that would no longer
> be supported.  Probably unlikely, though, OK....

They are sourced by a shell, but they are read and written by tools.
SUSE has YAST, Debian has debconf.  I assume redhat has something
similar.
Those tools might let some shell syntax through, but people who try
games like that are already taking a risk I think.

>
>> - nfs-config.service is removed, because it isn't really needed with
>>   the above.
>> - documentation for all the above is provided, including a new
>>   nfs.systemd man page which gives the bigger picture.
>
> Still looks pretty good to me.
>
> I'm a little worried about user interface churn.  We're not done yet
> explaining that people have to run nfs-config.service after changing
> things, soon we'll start telling them oh, never mind about that and oh,
> by the way, you may want to start migrating your configuration to
> /etc/nfs.conf....

Did we tell people to run nfs-config.server?  The intention was that it
wouldn't be needed.  Any systemd transaction that needed nfs
configuration should run the command once.

Commit: c4940fad2a73 ("systemd: ensure nfs-config service is re-run as need=
ed.")

should have made that happen.

Yes, some migration is needed.  I see distros as the primary target for
that, and the 'include' and '$name' functionality is supposed to allow
that to be transparent.  i.e. the configuration stays as it is, it just
gets into nfs daemons by a different path.
If people want to edit /etc/nfs.conf directly, then they are on their
own, just like people who edited their systemd unit files directly,
or created replacements in /etc.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhHQAEACgkQOeye3VZi
gbnYUhAArQoTcbzhn+hEGqRk5wuDpz5BYbDWY5NHfJFQK/gnDJF9pAOh7xDnTf1h
bCiR/85yGddTWu0YYb3bux/eJpdSYfksYWO+TDkflzGsgnfzMwAlxtoHnd6j4+vI
TZFo0OBjKGFBHfvI9Ml2nM2PfAhKy9BGXNT4ldJbfaHIrHBPIgo+53fXxzL1agdC
722b1R4C/TroQWUAchmfx6ZHnXnPCmQGxqt3tg0bgN3FfM+aqW8leBkWCl7YPzjv
ftnYa9UXyKVGfGAnbeclMrmYBaB6EdI8HONHmRuB4u6zJeV00SW8KQ2Fa+UqP0IV
GrAo5LrWNeEHQUmp+D7jng8RSfNyPffnKrE4xnCgDuodWNA34Ko8I6U85QvT3uGd
YP645RXRf5bv8wK8u+bmWoVeV+kM5Slt5q7V2NtTxUH/z8fc08oiBE68niutjq9n
YkEACrHm2X06YHaomMK2bhWvIbfnbB8G3T+YRp8CEIn1/lq4BGu3kI08XHmhJKbc
pE/8eMo4vvmW/0jFro7kr+H5H7e5J4WswqxejT8ZDc3RklyfslM/kwYlWs8SDmuK
fKD1q/BYT07PU1tIjMVBvNj2eK2PCnpSLQ5mAGZkfW0X7KlsEtAlbEaq7skbaNNb
2Nkjn8+vZHjDq7cuncWuPdSWa11bwehPRIQJMoXxn7iOOsK/MYE=
=NJtF
-----END PGP SIGNATURE-----
--=-=-=--
