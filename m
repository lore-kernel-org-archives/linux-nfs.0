Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53352 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965589AbeBMT5N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 14:57:13 -0500
From: NeilBrown <neilb@suse.com>
To: "Wang\, Alan 1. \(NSB - CN\/Hangzhou\)" <alan.1.wang@nokia-sbell.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
to: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 14 Feb 2018 06:57:06 +1100
Subject: Re: A special case in write_flush which cause the umount busy
In-Reply-To: <VI1PR07MB342127E2A55088F691693A3BA2F00@VI1PR07MB3421.eurprd07.prod.outlook.com>
References: <VI1PR07MB342127E2A55088F691693A3BA2F00@VI1PR07MB3421.eurprd07.prod.outlook.com>
Message-ID: <87inb0r7cd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 11 2018, Wang, Alan 1. (NSB - CN/Hangzhou) wrote:

> Hi,
>
> I have a test case on mount/umount on a partition from nfs server side. A=
nd encounter a problem of umount busy in a low probability.
>
> The Linux version is 3.10.64 with the patch "sunrpc/cache: make cache flu=
shing more reliable".
> https://patchwork.kernel.org/patch/7410021/
>
> After some analysis and test in many times, I find that when it failed to=
 mount, the time "then" and "now" are different, which caused the last_refr=
esh is far beyond the flush_time. So this cache is not expired and won't be=
 clean at once.=20
> Then the ref in cache_head won't be released, and mntput_no_expire didn't=
 be called to decrease the count. That caused the umount busy.
>
> Below are logs in my test.
>
> kernel: [  292.767801] write_flush 1480 then =3D 249, now =3D 250
> kernel: [  292.767817] cache_clean 451, cd name nfsd.fh expiry_time 79048=
5253, cd flush_time 249, last_refresh 369, seconds_since_boot 250
> kernel: [  292.767913] write_flush 1480 then =3D 249, now =3D 250
> kernel: [  292.767928] cache_clean 451, cd name nfsd.export expiry_time 2=
049, cd flush_time 249, last_refresh 369, seconds_since_boot 250
> kernel: [  292.773229] do_refcount_check 283 mycount 4
> kernel: [  292.773245] do_umount 1344 retval -16
>
> I think this happens in such case that the exportfs writes the flush with=
 current time, the time of "then". But when seconds_since_boot being called=
 in function write_flush, the time is on the next second, so the "now" is o=
ne second after "then".
> Because "then" is less than "now", the flush_time is set directly to orig=
inal "then", rather than "cd->flush_time + 1".
>
>
> And I want to change the condition as below. I'm not sure it's OK and has=
 no effects to other part.

I think this change is safe.  It is a bit of a hack, but the "flush"
interface was actually very poorly designed and I don't think it *can*
be implemented cleanly.
Maybe we should just ignore the number written in and *always* flush
the cache completely.  That is was it always wanted.

See below.

Bruce: do you have any thoughts on this?

Thanks,
NeilBrown

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index aa36dad32db1..43f117d1547e 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1450,7 +1450,7 @@ static ssize_t write_flush(struct file *file, const c=
har __user *buf,
 			   struct cache_detail *cd)
 {
 	char tbuf[20];
=2D	char *bp, *ep;
+	char *ep;
 	time_t then, now;
=20
 	if (*ppos || count > sizeof(tbuf)-1)
@@ -1461,24 +1461,24 @@ static ssize_t write_flush(struct file *file, const=
 char __user *buf,
 	simple_strtoul(tbuf, &ep, 0);
 	if (*ep && *ep !=3D '\n')
 		return -EINVAL;
+	/* Note that while we check that 'buf' holds a valid number,
+	 * we always ignore the value and just flush everything.
+	 * Making use of the number leads to races.
+	 */
=20
=2D	bp =3D tbuf;
=2D	then =3D get_expiry(&bp);
 	now =3D seconds_since_boot();
=2D	cd->nextcheck =3D now;
=2D	/* Can only set flush_time to 1 second beyond "now", or
+	/* Always flush everything, so behave like cache_purge()
+	 * Can only set flush_time to 1 second beyond "now", or
 	 * possibly 1 second beyond flushtime.  This is because
 	 * flush_time never goes backwards so it mustn't get too far
 	 * ahead of time.
 	 */
=2D	if (then >=3D now) {
=2D		/* Want to flush everything, so behave like cache_purge() */
=2D		if (cd->flush_time >=3D now)
=2D			now =3D cd->flush_time + 1;
=2D		then =3D now;
=2D	}
=20
=2D	cd->flush_time =3D then;
+	if (cd->flush_time >=3D now)
+		now =3D cd->flush_time + 1;
+
+	cd->flush_time =3D now;
+	cd->nextcheck =3D now;
 	cache_flush();
=20
 	*ppos +=3D count;


>
> --------------------------------------------------------------------------
>        then =3D get_expiry(&bp);
>        now =3D seconds_since_boot();
>        cd->nextcheck =3D now;
>        /* Can only set flush_time to 1 second beyond "now", or
>        * possibly 1 second beyond flushtime.  This is because
>        * flush_time never goes backwards so it mustn't get too far
>        * ahead of time.
>        */
>        if (then !=3D now)
>               printk("%s %d then =3D %d, now =3D %d\n", __func__, __LINE_=
_, then, now);
> -      if (then >=3D now) {
> +     if (then >=3D now - 1) {
>               /* Want to flush everything, so behave like cache_purge() */
>               if (cd->flush_time >=3D now)
>                      now =3D cd->flush_time + 1;
>               then =3D now;
>        }
>
>        cd->flush_time =3D then;
> --------------------------------------------------------------------------
>
> Best Regards,
> Alan Wang

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqDQxIACgkQOeye3VZi
gbkL5w/9Eunybj16rujgplIf49Sv5SpHVWqte7AhI6WJKKA4GH2YhOFxNn3bcqhN
wV+jvSo3qzyqW0mJN3qOO24PxOwETu958xiYad3kPyZxQhRAlIIeFZu54wLhRXZ8
9jn+B4Ew7SlW8g/99wu6ZiLSALllJ5XMGoeATD7c/2mIUubJ1X6TO3isjN0JYTH/
Rrjht3m2u0QoakdnLmV4MwR38c7mTzMXbd9XbS7aSiuloirTwBGZ9Hn4rpTDmC8n
mEUaLTA6l1O98bPF6vEXzkz/X9xD0rJv++rLaMVYbQJrNV9l5lfheB/XIFjuAOx2
euvmHKTwx5D4BrnZFB3qS5Km+txHDS5+iirKcbbhc69az+hmr+EEm7KV6AiMfBhU
F9rXTj7I6KETUoMt16LahefQ+wuRJ/hS6eafcbS9ucjfYkSRvQXAKAKdld/nDRyt
IKe/CjLbvqw+CD/GPd5/yXI9LldWDbn/QTaEyZ/K+Z+S5SCTTXW3wALPo8XI+1mm
rdL7XMkIf2D9HyimK2r7it7PfP81uytA88CajFn5CITOqu+3gcpmYBvWDjud0qoC
wTXh3PQELh1h39DQAD86lqsNjOC9fSMb6LtZK1zTos/aVJLHoW94ACjo9BMzyd83
TElciidw6c8Zu6MjZy8F4uxz4rRne9lYiFBFb5MQfjWeDqT0MuM=
=5V5W
-----END PGP SIGNATURE-----
--=-=-=--
