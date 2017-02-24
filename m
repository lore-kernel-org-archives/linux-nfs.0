Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56986 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751246AbdBXC2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 21:28:08 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "steved\@redhat.com" <steved@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 24 Feb 2017 13:27:57 +1100
Cc: "bfields\@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: Change the default to enable all minor versions unless told otherwise
In-Reply-To: <1487900531.114433.1.camel@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com> <20170224003344.113724-2-trond.myklebust@primarydata.com> <20170224003344.113724-3-trond.myklebust@primarydata.com> <87ino0qtf4.fsf@notabene.neil.brown.name> <1487900531.114433.1.camel@primarydata.com>
Message-ID: <87fuj4qq4y.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 24 2017, Trond Myklebust wrote:

> Hi Neil,
>
> On Fri, 2017-02-24 at 12:17 +1100, NeilBrown wrote:
>> On Thu, Feb 23 2017, Trond Myklebust wrote:
>>=20
>> > Instead of letting the kernel decide, default to enabling all
>> > versions,
>> > and let the user be more specifc in /etc/nfs.conf or on the command
>> > line.
>>=20
>> What is your rationale for this?
>> I think there is value in allowing the kernel to support a version
>> while
>> disabling it by default.=C2=A0=C2=A0This allows it to be used for
>> experimentation,
>> without much risk of it being used in production until it is deemed
>> to
>> be really ready.
>
> I think we can still do that by having the kernel simply not report
> that version. You'll note that -V4.x and -N4.x are allowed whether or
> not the kernel is reporting a version 'x' in /proc/fs/nfsd/versions.
>
> IOW: if you want to make the version not appear by default because it
> is unstable, then you probably don't want it to appear when the user
> does '+V4' either so you might as well hide it in
> /proc/fs/nfsd/versions too.

That seems reasonable - possibly even better than the current approach,
though it is hard to be sure without actually trying it out for a while.
I haven't poured over the patches enough for a reviewed-by, but
  Acked-by: NeilBrown <neilb@suse.com>

thanks!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlivmi0ACgkQOeye3VZi
gblYlhAAsIbQ0E74UAQPdb03mDHOKnl6bhEo1+5Z6sLA6wdbBqLCRmvanJnF+bQE
JDwkxjr8riUV6qhbHR0HoRMI51Te6Kbl7bDa9FYLCdFsoKafJJ014aiMdx5kux/9
FNLL6cX3psrduurjqyi8xSlytUMiZLABppz/UuLPZOhiEbQ4xBnkYB5k5WF9qBIP
tztv0Q5quUJF2kCrbvU1pNJCa1yArJNVmUgDwM8BdH88nsWtY4kIhvcS8zfqMXGj
nmXR700bRwuEunG9DblImKc4j9dMqeOsanXatBc9H0NKVr7o79kVq64k7nMyToL0
VIewpHCjZT/VAasZEGy75DDEacJyzO4sJep8m0is7TvHDa/h50cTZEwjclyrXTrw
G2840hZX30OqlBvED/JNqzNZNxPH0F26CtaStlrefsQEngO/lDwdUFczVj0NSpYw
VyDCvJar7LOJZ3KnnuXQf/GkuZjM2gXvlPeblVTybkqy+prMAn1O5aL5slNoMByO
aT1SOZJcAmo9DcJqZJUN3jctg5e6iy/zRwkmKSxGgUyzBGmnWKfu5oeG73PSjmk8
Tf2LKhoOuT2bjZirWtrmyu2amyAsatqBmZ2WOpPL70eRAEaIDd9+8CMG+0wFYgs1
6thQOvJH4wiZQ47D5/TGkXQ/jFMHbbtYIe0F/3+HNh05phOU8co=
=7lRy
-----END PGP SIGNATURE-----
--=-=-=--
