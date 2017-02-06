Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43277 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750995AbdBFVH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Feb 2017 16:07:58 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 07 Feb 2017 08:07:13 +1100
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSDv4: use export cache flushtime for changeid on V4ROOT objects.
In-Reply-To: <20170131143855.GA5727@fieldses.org>
References: <87mve9rs0z.fsf@notabene.neil.brown.name> <20170130153517.GC24786@fieldses.org> <8737g0rxm2.fsf@notabene.neil.brown.name> <20170131143855.GA5727@fieldses.org>
Message-ID: <87k293vxj2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 31 2017, J. Bruce Fields wrote:

> On Tue, Jan 31, 2017 at 09:28:37AM +1100, NeilBrown wrote:
>> On Mon, Jan 30 2017, J. Bruce Fields wrote:
>>=20
>> > On Mon, Jan 30, 2017 at 05:17:00PM +1100, NeilBrown wrote:
>> >>=20
>> >> If you change the set of filesystems that are exported, then
>> >> the contents of various directories in the NFSv4 pseudo-root
>> >> is likely to change.  However the change-id of those
>> >> directories is currently tied to the underlying directory,
>> >> so the clinet may not see the changes in a timely fashion.
>> >
>> > Oh, good catch.
>> >
>> >> This patch changes the change-id number to be derived from the
>> >> "flush_time" of the export cache.  Whenever any changes are
>> >> made to the set of exported filesystems, this flush_time is
>> >> updated.  The result is that clients see changes to the set
>> >> of exported filesystems much more quickly, often immediately.
>> >
>> > And, a clever solution, as usual....
>> >
>> > I wonder if it's completely right yet, though.  Off the top of my head:
>> > can't the client see the new flush time before it sees the new content=
s?
>> > If so, a client that caches both during that window could cache the old
>> > contents indefinitely.
>>=20
>> uhm....
>> Yes, it could see the new flush time before it sees the new contents.
>> When it sees that new flush time (i.e. new change attribute), it will
>> invalidate its cached contents and ask for the contents again.
>
> The problem comes if it's still possible for the client to read (and
> cache) the old contents at this point, in which case the client's cache
> will incorrectly associate old contents with new change attribute.

I agree with this.

>
>> It will then definitely get new contents.
>
> So the problem with changing change attribute before contents is:
>
> 	- client retrieves old contents and new attribute, caches.
> 	- client revalidates cache at an arbitrarily later time, sees
> 	  it's still the new attribute, continues caching old contents.
>
> So usually I believe you want the two changes--contents and change
> attribute--to be atomic or, if that's not possible, for them to be
> changed in that order.

I believe that setting ->flush_time atomically effects both changes.

>
> I haven't thought through how that applies to this case, but I think it
> should be possible if in-progress rpc's hold references to objects in
> the flushed cache?

How would it do that?
In NFSv4 'READDIR' and 'GETATTR' are separate operations.
If the client sends READDIR and then GETATTR, it must not assume that
the change number in the GETATTR reply implies anything about the
READDIR reply.
But it (presumably) sends them in the order other, so if GETATTR gets a
new change number, then when nfsd4_encode_dirent_fattr() calls
nfsd_crossmnt() it will find the changed to the exports table, though it
may need to wait for an upcall to complete.

You are right to be cautious, but I think ->flush_time effectively
provides the needed atomicity.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliY5YEACgkQOeye3VZi
gbkMAQ/+M8vwV6QCx+n+v24ey3r/yVbn/o29cSNg2FHBaBD7pimyEhCFqWh6C6Na
k7eMZytfrwVjvaALcMx1VqhVPNUdiu27X+pGBeDsi1h8fZ0sNsxZZiVOfpf9D80Y
3oy6TxNJ+1vB5ZVdInfd44u4A5cVws40SOHnschsIM18CRNsAgtu9vq9h9I/9eDr
3H1R7ntt+B97TrclVfJZlkjLz6iBoNoKXMNbCOJwhFa3JU+L+g9Xfkc/2Sl/pUhl
qwY/17sbW1TOiNXX/SDGBGyChlIBERu7yZm5b4FKXE1z3qR95CtnAwllqrws1VAY
E8fuHyfyPhJH0dNGBWmPrOp1uQ/b1xhwflVdIi9TzD8Z6ZADa4jeoR81iI6nIUHX
fq3I2z/3sFzS/iam+2F06LprU5Mab6Xl4X3gX0uNIoG6xgZ8UnavS/dEA3HIY746
fiW4kBcrzmv+vplTKMu5V0e9KAIwe+tKZ/tYJYaRLudaHCYQEPrw7KLcw4jGbyz4
lQ8jeIvMl1O9pcJxlspJtVaBstshzoitlq1rTtvhDScVIbDD5WR0CU3WF3ETJGy8
daXuM3dQ3UhkvinXDhGp9Z6dDilK9UfAO9I6HckU829IUNAGQHmA62quNprlSVYP
JYMQ43/B5fgu5fH4Esit76Cw1rTmwcegQNQTdJl5sMUuGaGRCD8=
=5btc
-----END PGP SIGNATURE-----
--=-=-=--
