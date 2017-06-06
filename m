Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37802 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751436AbdFFVtf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 17:49:35 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>
Date: Wed, 07 Jun 2017 07:49:24 +1000
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login> <87tw43fgrf.fsf@notabene.neil.brown.name> <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
Message-ID: <87lgp4dbx7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 06 2017, Steve Dickson wrote:

> Hello,
>
> On 05/29/2017 06:19 PM, NeilBrown wrote:
>>=20
>> Systemd does not, and will not, support "bg" correctly.
>> It has other, better, ways to handle "background" mounting.
> The only problem with this is bg mounts still work at least
> up to 4.11 kernel...=20

I don't think this is correct.
In the default configuration, "mount -t nfs -o bg ...."
runs for longer than 90 seconds, so systemd kill it.

A working "bg" mount would successfully mount the filesystem is the
server came back after 5 minutes. If you use current systemd in the
default configuration, it won't.

bg mounts do work sometimes, but I don't think they are reliable, and
there seems to be no interest in changing this.
Maybe the text should say "Systemd does not, and will not, reliably
support "bg" mounts...".


>
> It appears there is a problem with a 4.12 kernel. The mount no=20
> longer errors out with ECONNREFUSED it just hangs in the=20
> kernel trying forever... It sounds like a bug to me but=20
> maybe that change was intentional.. Anna?? Trond???

Might be related to my patch
  [PATCH] SUNRPC: ensure correct error is reported by xs_tcp_setup_socket()

sent 25th May.

>
> So I'm a bit hesitant to commit this since not accurate, yet.
>
> Finally, the whole idea of systemd randomly/silently=20
> strip off mount options is crazy... IMHO...=20

It isn't exactly systemd, it is systemd-fstab-generator.
The options lists in /etc/fstab are not all equal.  Some
are relevant to /bin/mount, some to mount.nfs, some to the kernel.
I think /bin/mount processes the option lists before passing it
to mount.nfs.  There is no intrinsic reason that systemd-fstab-generator
shouldn't do the same thing.

>
> Just because a concept that has been around for years
> does not fix well in the systemd world it gets
> rip out??? IDK... but I think we can do better than that.

I could suggest that automount is uniformly better than bg.  Give how
long automount has been around, and how easy it is to use with systemd,
it might be time to start encouraging people to stop using the inferior
technology.

I could say that, but I'm not 100% sure.  The difference between
automount and bg is that with bg it is easy to see if the mount has
succeeded yet - just look for an empty directory.  With automount,
you'll typically get a delay at that point.  We could possibly wind down
that delay...

>
> Note, the 'bg' is used by clients that do want their
> booting to hang by servers that are down so if the=20
> option is rip out, boots will start hang. This
> will make it very difficult to debug since the bg
> will still exist in fstab.

Not exactly.
Current default behaviour is that systemd will wait 90 seconds, then
kill the mount program and fail the boot.  If we strip out "bg", the
same thing will happen.

I'm OK with the patch not being applied just yet.  I think we need to
resolve this issue, but it isn't 100% clear to me what the best
resolution would be.  So I'm happy to see a conversation happening and
opinions being shared.
I'd be particularly pleased if you could double check how "bg" is
currently handled on some systemd-enabled system that you use.
Does the mount program get killed like I see?  Does boot succeed if
there is a bg mount from an unresponsive server?

Thanks,
NeilBrown


>
> Again, the whole concept of systemd messing with mounts options
> is just not a good one... IMHO..=20
>
> steved.
>
>>=20
>> Explain this.
>>=20
>> See also https://github.com/systemd/systemd/issues/6046
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  utils/mount/nfs.man | 18 +++++++++++++++++-
>>  1 file changed, 17 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index cc6e992ed807..7e76492d454f 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -372,6 +372,21 @@ Alternatively these issues can be addressed
>>  using an automounter (refer to
>>  .BR automount (8)
>>  for details).
>> +.IP
>> +When
>> +.B systemd
>> +is used to mount the filesystems listed in
>> +.IR /etc/fstab ,
>> +the
>> +.B bg
>> +option is not supported, and may be stripped from the option list.
>> +Similar functionality can be achieved by providing the
>> +.B x-system.automount
>> +option.  This will cause
>> +.B systemd
>> +to attempt to mount the filesystem when the mountpoint is first
>> +accessed, rather than during system boot.  The mount still happens in
>> +the "background", though in a different way.
>>  .TP 1.5i
>>  .BR rdirplus " / " nordirplus
>>  Selects whether to use NFS v3 or v4 READDIRPLUS requests.
>> @@ -1810,7 +1825,8 @@ such as security negotiation, server referrals, an=
d named attributes.
>>  .BR rpc.idmapd (8),
>>  .BR rpc.gssd (8),
>>  .BR rpc.svcgssd (8),
>> -.BR kerberos (1)
>> +.BR kerberos (1),
>> +.BR systemd.mount (5) .
>>  .sp
>>  RFC 768 for the UDP specification.
>>  .br
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk3I2YACgkQOeye3VZi
gbntMA//X96Zj20+ffcM5JDRsTDB2S4H2uraAudfKflyjK1HSlxPY+2sYR553A65
vQCSU8mbct8zJMLyWX9Jg2PyvKF5FxFjhRj7gFAY0s8LPDqAecdHKNKDO5hZ5TYy
coqVq6BDLsaZxrn/1SWdf/o1bjQuc3vbwHiteBH6WZCPf3RYqJNK+vXdX7IF0OZZ
p7LMyYeHjKscJ95CfdVJo6pXA9+N7/A/HiUpE08N5B7uEy9xjmjADTeUzFnvyW0J
rpjTqWbTm0/b/6J7XkXYaUCv0UF2ktHZcZ9fesZmFVgFZtdH+gBWMHUFLJQzIM9L
7URIG3eLjO+0Ncmr/E6hjsu1v+Wan/XqGLQ54K98KaIJ8Kxsclzj4w/HN4RgGXI3
/o4AMZgcDvnzWaSEwCldxBK/DfVb7O8NA7F/U1m7Xgo8TuyXl+I9VjR91okApdIR
GdKHc+OKBH6RgXoqvUVO5yQN5LNIkxUmCRoss1ibsZgMlXwLXkEfv/4iFJjoYvod
7G71fl1Dngzs53AaAhgMWgnPheY5xJyniGSnqT8LiGNi00FtJH8MQGAZ6fHVcBFc
97sYB1kxkw7/iXWzjWyA5MYPSfQRBdQCICpsqvvT4SVd25ABoG6sqxTDy5LF0JPW
XKR3eeeDKsMDBj9MvLbteTBZDX8jqkozEhjzgMrSv5RyWFN2vzE=
=rQPl
-----END PGP SIGNATURE-----
--=-=-=--
