Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37654 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbcCVCVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 22:21:44 -0400
Subject: Re: Making an interface for alternative data streams
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <56F03945.40208@gentoo.org> <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org> <20160321223627.GA12999@thunk.org>
 <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
 <20160322001255.GA2353@fieldses.org>
 <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
Cc: Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Steve French <smfrench@gmail.com>
From: Richard Yao <ryao@gentoo.org>
Message-ID: <56F0AC2A.30300@gentoo.org>
Date: Mon, 21 Mar 2016 22:21:30 -0400
MIME-Version: 1.0
In-Reply-To: <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="6XkGA8xcGB8KRDp1rFRKsgo9FgV3vTMJk"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6XkGA8xcGB8KRDp1rFRKsgo9FgV3vTMJk
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/21/2016 09:02 PM, Richard Yao wrote:
>=20
>> On Mar 21, 2016, at 8:12 PM, J. Bruce Fields <bfields@fieldses.org> wr=
ote:
>>
>>> On Mon, Mar 21, 2016 at 11:48:04PM +0100, Cedric Blancher wrote:
>>> Old invalid argument, and Sophos and Symatec look there as well.
>>>
>>> If it was a bad idea, why has Linux fs attributes which are almost th=
e
>>> same as O_XATTR except that they use a custom api? Why does Macos hav=
e
>>> alternate streams (called forks)? Why did Solaris adopt it long ago
>>> (and still gets support questions about it - just saying before
>>> someone argues that no one uses THAT)?
>>
>> Could you point us at some of those users?
>=20
> I am told that Samba users would love this functionality.

Someone pinged me in IRC to let me know that Steve French was talking
about this earlier this month:

> Have there been any suggestions on how to list alternate data streams
> on a file other than using a pseudo-xattr as ntfs-3g does (querying
> xattr ntfs.streams.list - see http://linux.die.net/man/8/ntfs-3g)?

http://permalink.gmane.org/gmane.linux.kernel.cifs/11681

Windows appears to have name-value pair attributes and alternative data
streams in separate name-spaces simultaneously.


--6XkGA8xcGB8KRDp1rFRKsgo9FgV3vTMJk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW8KwvAAoJECDuEZm+6ExkTPAQAJriXKo8Ex5H1TSAGM+E9roi
drlGqbIgCaPBAocUVWTp+oTUPoqzlZq8/NsQhAe8cKJhuTHReaU0bNAnzFVniRgx
G80HyU7Cmd/mCDix42XhkvHbXR3j881F68D83OeA0651jOddWV6Z7govSwKv/uwO
wZt6vYUWrjNgeAsGT8LvkQjZ+qC/hLCWJOAJWfG4HoDvkt429VgCjtnYXKGC9fX5
5KGeg/JexcHywxeclYrsIX7HtiOorrkocRYwR7tuPC7dR009+sSlGjXcgf2UHQ9l
8cJ/PzNIzO1i6xq5pqjNHsdsDeAhaB1cQKNiOG+7kJkzw/i/1jbZKkHQ0KwYHAOI
RPsJlUlwkVIs+xwgQa9RDozt6tsqdZJMRaUBeldDjTQT0wIKPsI8SdDQdg8+7C7H
QxiDIdelMZ9JgQPHsz2ctmEnocikt77jHqnyD/J2GVy6e0lLoXhu/orASXXixtS1
yPb47fMDTn383KDWvRbDG8rk7eCSM9WQ6NN56abJrBrJWZ3bhG3gTDQk79dxAZjU
f7RsmVYO8GBPLWrvGnRH1sKugkwy00xp92xpq/hSSgA2idyJQs07KB5+xmmjwxjy
cNZnk0tCtxoPhso3u+dFB2DsJTH9RrSABHh5cki3o+RWqoidQO2QoWlH4E7Q0W6V
jga5gxYJ9s620vpuupUq
=nl65
-----END PGP SIGNATURE-----

--6XkGA8xcGB8KRDp1rFRKsgo9FgV3vTMJk--
