Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37869 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932141AbcLGXPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 18:15:05 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 10:14:54 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
In-Reply-To: <20161207180843.GA20626@parsley.fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble> <148065110833.28046.2561331715736018574.stgit@noble> <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com> <87r35k4rcr.fsf@notabene.neil.brown.name> <35ca5ad2-39db-a46b-13b2-a2e5128793a0@RedHat.com> <20161207180843.GA20626@parsley.fieldses.org>
Message-ID: <877f7bs55d.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 08 2016, "J. Bruce Fields" <bfields@redhat.com> wrote:

> On Wed, Dec 07, 2016 at 09:44:25AM -0500, Steve Dickson wrote:
>> >=20
>> > I do wonder if this is ever valid though.  Why do we allow minor
>> > versions to be enabled/disabled?
>> IDK... I think Trond did this... you know...
>> when in doubt... blame Trond! 8-)=20
>
> Or Benny, 8daf220a6a83 "nfsd41: control nfsv4.1 svc via
> /proc/fs/nfsd/versions".
>
>> > Does it make any sense to enable a non-contiguous set of minor version=
s?
>> I don't think so... Talk about handing people rope! ;-)
>
> I can't think of a reason either.
>
>> > Should we just have a maximum NFSv4 minor version?
>> Maybe..=20
>
> If you do that then I'd allow a minimum too.

Why?  I'm trying to understand why you would ever want to turn disable a
particular minor version.  I could equally well ask myself "why specify
a maximum"...

Benny's patch only suggests that it removes the need for
CONFIG_NFSD_V4_1, but why was that needed?
Maybe it is just to disable buggy code if some version is found to have
an inconvenient bug?  The client, by default, tries 4.2, then 4.1, then
4.0.  Older clients might start elsewhere.  So just disabling unreliable
versions individually does seem to make sense.

I note that Benny's original patch disabled v4.1 by default, and
required it to be explicitly enabled.  The current kernel enables all by
default, and requires them be explicitly disabled is required.
My current nfs.conf code will disabled unwanted minor versions, but not
enable any that are already disabled ... I guess I could fix that.

.... it is a shame that we can only enable/disable minor versions
when there are no nfsd threads running.  The justification for
failing if nfsd is active is fairly lame, and only applies
to major versions.  If minor versions could be changed at any time,
then it could be a simple function of rpc.nfsd, and the config
file would never need to enable things, only disable them.

Is there any other reason to disable minor versions, other than to avoid
buggy code (either in server or client)??


Actually.... I have a related question that I keep meaning to ask, but
haven't.

What are the circumstances where NFSv3 should be preferred over NFSv4
(assuming up-to-date kernels on server and client)?

I can think of:
 - NFSv3 is safer if you might need to support loop-back mounts
   as I don't think NFSv4 state management can reliably make forward
   progress against memory pressure.  In particular, creating the
   state-manager thread can deadlock waiting for an NFS write.

 - If you want fast-failover from one server to another,
   NFSv3 is probably faster as it only imposes the grace-time on
   lock requests.  NFSv4 imposes it on OPEN and so READ/WRITE
   as well.

 - NFSv3 is preferred if (for some weird reason) you need
   to use UDP.

Are there any others?  Are there any similar reasons to prefer a smaller
NFSv4 minor version over a larger one?

Thanks,
NeilBrown

>
> --b.
>
>> > I was trying to duplicate the current functionality as closely as
>> > convenient.  That might not be best in this case.
>> You did a good job... this is definitely a nit.
>>=20
>> steved.
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhIl+8ACgkQOeye3VZi
gbk8Og/+NwYQD27RSBNGKmwW4GrkG+FUqZeZH/BnPZj4RJIQEZLkVUMHpFsacPiM
WUp7oVvZPp9CG1KacRKBvYRqmj5qO5VgLbEnEnWpkBQV7vAcdmYqmg/fQULo+v+o
3xtuZt/w9E3wNIiKxym+JkPqlZ0ecsiJ3zQK+TZF4q8ESa5reyJx+Qkl20XFbvpG
6bqLMPt29k21P3fgehlXs1F7RISOBfhbFelmq77H0Pe33AWw3udzEpKFCCcaRY0V
ohs69STJ+36fOhDyLKDz/6DNjxif9bp8QOLmDrio0mGyjptOqhXTaQV34ft8XWET
1tya3lZ6HjqeetJ2lgpvRNhmAAlIu9MM5Vli6KBZrZ7k3q0hh4DkA3knX71b+Mvx
yHJx+AasejSvJTKHnfGaQIFb5m1/irIGhadL2iMVhF+FIH1c1cmHTCot0iImnddr
gXBJrOSVrL2de8ZH0tF9yam72Fyp6KpVfbhAdlgbNhj0x7EVHQyN+sAOXgkHoxE3
vTLqWKDQH1HidebKmQzHPbZXY/Ht4I79CFwoHWsDuHjpxNOmc3wkBF7YZcnCpjYx
9ZCDgaXI3MUs0td3KO5bSV1UthCwjz3kjEHsu8WPxsTXdUUFs/XnEYXWdY9cn0fH
2KdzSJka70OXMXLowV5sdXmJkHlju/GnnI7hRKL4e5N3pIqCMbw=
=gBux
-----END PGP SIGNATURE-----
--=-=-=--
