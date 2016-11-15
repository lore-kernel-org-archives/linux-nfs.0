Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51974 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751611AbcKOU2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 15:28:31 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 16 Nov 2016 07:28:21 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to /run/rpcbind
In-Reply-To: <85b23fdd-8dd4-9614-88ef-9691c3cdba3b@RedHat.com>
References: <877f8almcf.fsf@notabene.neil.brown.name> <669e90b0-6011-7b82-4e37-f1e3bf292026@RedHat.com> <87k2c5i71h.fsf@notabene.neil.brown.name> <85b23fdd-8dd4-9614-88ef-9691c3cdba3b@RedHat.com>
Message-ID: <87h978ij2y.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 16 2016, Steve Dickson wrote:

> On 11/15/2016 01:36 AM, NeilBrown wrote:
>> On Tue, Nov 15 2016, Steve Dickson wrote:
>>
>>> On 11/10/2016 10:36 PM, NeilBrown wrote:
>>>> rpcbind can save state in a file to allow restart without forgetting
>>>> about running services.
>>>>
>>>> The default location is currently "/tmp" which is an over-used
>>>> directory that isn't really suitable for system files.
>>>> The modern preferences would be a subdirectory of "/run", which can
>>>> be selected with a ./configure option.  That subdirectory would still =
need
>>>> to be created by something.
>>>>
>>>> It is trivial for rpcbind to create the directory itself, and harmless
>>>> to try if it already exists, so:
>>>> - add a "mkdir" when saving state data
>>>> - change the default to /run/rpcbind (currently used by Debian)
>>>> - remove the default settign in the code, just use the one
>>>>   in configure.ac
>>> I'm all for move the warmstart directory to /run but why don't we have =
systemd
>>> create the directory via a  tmpfiles.d( config file... some like
>>>
>>> #Type Path      Mode UID GID Age Argument
>>> D  /run/rpcbind 0700 rpc rpc - -
>>>
>>> The only thing I'm not sure about is how it would get installed...
>>> I guess it would some type of Makefile.ac entry??
>> Because not everyone uses systemd?
> Yeah... I figured as much.
>> Someone at SUSE recently moved the state directory to /run/rpcbind and
>> used tmpfiles.d exactly as you describe to create /run/rpcbind.  Then
>> found they needed to do something extra and different for dracut.  I
>> haven't looked into why, but it is presumably because while dracut does
>> use systemd, it doesn't use it quite the same way that normal system boot
>> uses it.
> I didn't have this problem when I move rpcbind in RHEL7 to use /run/rpcbi=
nd via tmpfiles.d
> The biggest problem I had was migrating the warmstart files to the new pl=
ace.
> Having /run/rpcbind exist after boot made that much easier.=20

That would be a bit fiddlely.
Might be easiest to create a symlink /run/rpcind -> old-location when
the package is installed, then let the proper directory be created on
boot.
Only then you cannot clean up the old directory at install time.

>> I've found this with configuring mdadm too.  I got the udev and systemd
>> configuration just right, and then found that while dracut uses udev and
>> systemd, I still need to add extra stuff to dracut.  And then there was
>> another boot environment which used udev but not systemd, so it needed
>> different tweaking.
>>
>> So I think we are less likely to run into strange problems if we just
>> get rpcbind to create its own directory.  Certainly rely on systemd to
>> do the things that systemd does best (like start the service), but don't
>> rely on it to do things we can easily do ourselves.
> Another potential problem is SElinux... Its never a fan of daemon creatin=
g things
> on the fly... but I guess that is my problem 8-)

rpcbind would only create the directory if it doesn't exist.  If you
need to create it with special SElinux things, there is no harm in doing
that first.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYK2/mAAoJEDnsnt1WYoG5VewP/jhPK8+4eB5HWSrAFPhNspiq
wh6fmLfVAUm0VVxKrPVcKS2qORbpR1hgYaUSbebI5knxNGHEpIeoCelgTP0sGYGA
A96gdBtwe5Vlj4+3QR/+/Qet/6T4KW1uUihxYTR3fbZZk2Tq+N0wAVWeqmiFGE+8
vjtltbAJep+5eEnZBz01m4d3jRTk/kdRGy2LUIUQkXmWUjxxkoXg4znxt8zDbDhq
S5wVByoOs9NIbXf+Ow8Pw/OgdLVKIiK8bUVJIDpgJzp4ziJTyX6oLbwO3+U5Z8G9
2bUntfU0JRXz+d5j3sBJHHKE9ZMf4Fvow2HBNU3kk/LxmqMC2IbWK/EFMUE+1HZf
ji5310X+l/SXr0AlUhM9UHSCyq05qakU5xHSp38Jt2hpagGPo3aYtW4ONB8LCdSv
SzRIi/aaUI5j0mH3tvmeTUHPplTl4DuaiGrRpMf/MkylCwLMFVqM5hHqF4qUfkFh
L/gl2GVUr6nOVd7okoY5J2q/yJz4gD97Mokx0NvMBipy0DpY7nn9lfFSpvuJ7sDm
3noP77ITLcdDoV32uLlyW7SWrtZr+aRUi3/gbbDqmo2t4V2j33zIcEBDcc/jjfZc
IMf28vxJPngA7wIQ1L/2KVXLV7Duk+fh6a4fSOeVtdV35nV/IgDB3GaeEMAQNmrI
B37+97nQpstepL9ia4So
=hm0I
-----END PGP SIGNATURE-----
--=-=-=--
