Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54577 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751830AbdKBVv0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Nov 2017 17:51:26 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 03 Nov 2017 08:51:16 +1100
Cc: Jeff Layton <jlayton@kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS Force Unmounting
In-Reply-To: <D32FC586-C351-4810-A4A0-1B2208307A55@oracle.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509460909.4553.37.camel@kernel.org> <8760aux1j5.fsf@notabene.neil.brown.name> <8EB53737-9126-4D26-A22F-D09639BE5130@oracle.com> <87bmklv8ls.fsf@notabene.neil.brown.name> <D32FC586-C351-4810-A4A0-1B2208307A55@oracle.com>
Message-ID: <87tvyctkmj.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 02 2017, Chuck Lever wrote:

>> On Nov 1, 2017, at 8:15 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Tue, Oct 31 2017, Chuck Lever wrote:
>>=20
>>>> On Oct 31, 2017, at 8:53 PM, NeilBrown <neilb@suse.com> wrote:
>>>=20
>>>> Maybe I could just sweep the problem under the carpet and use lazy
>>>> unmounts.  That hides some of the problem, but doesn't stop sync(2) fr=
om
>>>> blocking indefinitely.  And once you have done the lazy unmount, there
>>>> is no longer any opportunity to use MNT_FORCE.
>>>=20
>>> IMO a partial answer could be data caching in local files. If
>>> the client can't flush, then it can preserve the files until
>>> after the umount and reboot (using, say, fscache). Multi-client
>>> sharing is still hazardous, but that isn't a very frequent use
>>> case.
>>=20
>> What data is it, exactly, that we are worried about here?
>> Data that an application has written, but that it hasn't called fsync()
>> on?  Do it isn't really all that important.  It might just be scratch
>> data.  It might be event logs.  It certainly isn't committed database
>> data, or an incoming email message, or data saved by an editor, or
>> really anything else important.
>> It is data that would be lost if you kicked the powerplug out by
>> mistake.
>> It is data that we would rather save if we could, but data that is not
>> worth bending over backwards to keep a copy of in a non-standard
>> location just in case someone really cares.
>>=20
>> That's how I see it anyway.
>
> The assumption here is that any data loss or corruption when a
> mount is forcibly removed is strictly the responsibility of
> inadequate application design. Fair enough.
>
> One of my concerns (and I suspect Jeff is also worried about this
> use case) is what to do when tearing down containers that have
> stuck NFS mounts. Here, the host system is not being shut down,
> but the guests need to be shutdown cleanly so they can be destroyed.

Container-shutdown is a strong argument that MNT_FORCE is not enough and
that we need SIGKILL to actually remove the process.

Currently if there is pending dirty data on the final unmount of an NFS
filesystem, the superblock hangs around until the data is gone.  This
is good for shutting down containers, but it is a little weird - totally
different to every other filesystem.
If NFS were changed so that unmount blocked on the last unmount when
there is dirty data - just like every other filesystem - then we
probably need a way to "force" that unmount even in a container.

Thanks,
NeilBrown


>
> These containers may be sharing page cache data or a transport
> with other users on the host. In this case, we are trying to
> avoid a host shutdown to recover the stuck resources, and we
> do have the (possibly unnecessary) luxury of having a human
> being present to ask what to do to complete the recovery.
>
>
> --
> Chuck Lever

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAln7k1YACgkQOeye3VZi
gbkvjBAAvhsNgE4G/6wBRihp8V7f4FGDGJ/0Hk4q5QMoyofxg/l1KQTTXLkoHDcf
FUEqTPonYhj3L/MKqI1plJ5YcmiDqQnqbK6HT+Gbe3VbMik+vk5Zq8cvl7qpkPHz
DTyS8m72lSVwk/wJHVd1S3/xMV125tmlk75l+HxIV5UP2zo8opiREKdKg9FiqvnN
LzVpvChVx8mifMQmDzOPewAa1zU/3UBjGnE5s04QkMbs7gUQPHXvFI4dsqX7PMle
NwgfQNXNPGYqP+YqqmpemGvh+3DwTK/WUTUQ3kvAEZsP4evcnuiVwjVrKOMjXQ1x
PIdWxGoPmQ2x8DLBqtxqBEuvwLz3CSnM6225BTuiZrapjVyhM0jBBdjxibs0azYH
MhKCLG3GIY9qZ23QWRrsb1VfL50+BMsTizpmEiu5ZguJCpbEB0c5onsUuiFuv7FJ
o6T3jlUl9F/SlIn7KKh2ElIffbWCyflpNoMbENtsU7CWbqkAEbiQZ/8Lim8U8sDv
uk61UNqjEtMrWfZcst6ZbisjrY4W/hqPA6Nm4vX1nHmLylMbSUuZsQpYsCa40wus
iqdyTtMadZXRjN7UvGvH6v1T/KIgNUrF4Zd4ns2uoXSbNuizh1eVMkAHNDT52RaA
0ZHwiYK6kAr1QsAMPD83paqKr6Z8xrG2Wtd+qMaIOmX1pPeY0i4=
=I4GJ
-----END PGP SIGNATURE-----
--=-=-=--
