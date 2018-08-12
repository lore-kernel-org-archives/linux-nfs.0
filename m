Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56530 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728060AbeHMCfA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Aug 2018 22:35:00 -0400
From: NeilBrown <neilb@suse.com>
To: Bruce Fields <bfields@fieldses.org>
Date: Mon, 13 Aug 2018 09:55:07 +1000
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <20180812132100.GL7906@fieldses.org>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com> <20160321144349.GA12804@lst.de> <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com> <874lg3roua.fsf@notabene.neil.brown.name> <20180810170027.GF7906@fieldses.org> <20180810170312.GG7906@fieldses.org> <87d0uor11r.fsf@notabene.neil.brown.name> <20180812132100.GL7906@fieldses.org>
Message-ID: <878t5bqgx0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 12 2018, Bruce Fields wrote:

> On Sun, Aug 12, 2018 at 08:28:00AM +1000, NeilBrown wrote:
>> On Fri, Aug 10 2018, Bruce Fields wrote:
>>=20
>> > On Fri, Aug 10, 2018 at 01:00:27PM -0400, Bruce Fields wrote:
>> >> On Fri, Aug 10, 2018 at 11:29:33AM +1000, NeilBrown wrote:
>> >> > On Mon, Mar 21 2016, Nelson Elhage wrote:
>> >> >=20
>> >> > > That's correct. The other detail that seems to be important is th=
at
>> >> > > the user making the call must be different from the user owning t=
he
>> >> > > file. We've also been using user remapping on the server, so that
>> >> > > non-xattr calls succeed in that configuration.
>> >> > >
>> >> > > The reproducer James added in the bugzilla is:
>> >> > >
>> >> > > (on machine with IP address 10.1.1.1)
>> >> > > sudo mkdir /nfs_test
>> >> > > sudo useradd -u 10000 test_user
>> >> > > sudo chown test_user /nfs_test
>> >> > > echo "/nfs_test 10.1.1.2(rw,all_squash,anonuid=3D10000)" | sudo t=
ee -a
>> >> > > /etc/exports
>> >> > > sudo exportfs -a
>> >> > >
>> >> > > (on machine with IP address 10.1.1.2)
>> >> > > sudo mkdir /nfs_test
>> >> > > sudo mount -t nfs -o vers=3D3,noacl 10.1.1.1:/nfs_test /nfs_test
>> >> > > touch /nfs_test/foo
>> >> > > install -m 755 /nfs_test/foo /nfs_test/bar
>> >> >=20
>> >> > Did anything ever happen about this?
>> >> > I have a customer with a similar problem (in 4.4) but I cannot see =
any
>> >> > evidence of fixes landing in mainline.
>> >> >=20
>> >> > Problem happens with you have uid mapping on the server
>> >> > (e.g. anonuid=3D10000 as above) and a user with a different uid on =
the
>> >> > client attempts setacl on a file with that user.
>> >> > As anon is mapped to the owner of the file, setacl should be allowe=
d.
>> >> > However set_posix_acl() calls inode_owner_or_capable() which checks=
 if
>> >> > the client-side uid matches the visible inode->i_uid - they don't.
>> >> >=20
>> >> > Testing i_uid on the client is always incorrect for permission chec=
king
>> >> > with NFS - the client should always ask the server, either with ACC=
ESS
>> >> > or, in this case, by simply attempting the operation.
>> >> >=20
>> >> > Any suggestions how best to fix this?
>> >> > - We could move the responsibility for permission checking into
>> >> >   i_op->set_acl, but that would be a large change and might make it=
 too
>> >> >   easy for other filesystems to get it wrong.
>> >> > - we could have some sort of flag asking set_posix_acl(), but that's
>> >> >   rather clumsy.... maybe if i_op->set_acl_check_perm use that with=
out
>> >> >   testing ownership first??
>> >> > - we could copy
>> >> >     posic_acl_xattr_{get,set,list} into nfs together with functions
>> >> >     they call, modify set_posix_acl() to not test ownership,
>> >> >     and provide a local 'struct xattr_handler' structure for NFS.
>> >> >=20
>> >> > I don't really like any of those suggestions.  Can someone else do =
any
>> >> > better?
>> >>=20
>> >> Do we have important callers of inode_owner_or_capable() in the vfs (=
as
>> >> opposed to in individual filesystems), and do any of them pose a simi=
lar
>> >> problem for network filesystems?
>> >
>> > do_linkat()->may_linkat() looks kinda suspicious to me.  Or what about
>> > the O_NOATIME check in map_open()?  Just engaging in dumb grepping
>> > here....
>> >
>> > --b.
>>=20
>> NOATIME, both in open and fcntl, is rejected on NFS.  This seems valid
>> as there is no way in the protocol to ask the server to no update the
>> atime.
>>=20
>> Others I found we just short-cuts to avoid calling i_op->permission() if
>> the caller was an owner.  I don't *think* that would affect NFS much
>> ... though if an owner didn't have write permission, some things might
>> be incorrectly forbidden.  Maybe.
>
> OK, so not too important.  Still, it sounds like
> inode_owner_or_capable() is something people expect to work for any
> filesystem, so I wonder if there's a way to do that.  Or at least
> disable it.

We could add a new flag - MAY_OWN (or something) - to the flags
recognised by inode_permission() and i_op->permission().

If ->permission isn't set, inode_permission() uses
inode_owner_or_capable().
If it is, it gets to call that, or do whatever is appropriate.

Is this flag the same as NFS_MAY_OWNER_OVERRIDE or not....??

NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAltwyNsACgkQOeye3VZi
gbmhMRAAjF930McXzgeL3KbwL4kgpw3gsHqylUg09155p3iEdAIauVSkjxeaQOah
GJxbMHcMBj+JFgEPjuwI9x1YMUqC7jwe1qERn1qMkks7cULmv67YxlIPcqmko7G1
vfwaiVvbwc7xn4klpIe1TyvbDkCFcek49MePqmQ1Lpwx9hZ0i7PPfqP57urIr/rW
zaPGd/tb0nayXaYmLHGo4/nzKUgCUfwqweltiLKKzO0QBAD3Q8QqkjGoj/mV4ZiT
v8rnca+c2gVVafWtrl8DDyTfqHpvOe2/aQCai4cKfobVye73HwVZQLVKkamGta0a
HQUAeCWvg9ngvtySlLOT3/sSIhK+iJpJzO5KZFwsCUtpnlGEZ38LcTVMzBpOWLi+
mCykL9lKIS0Np8+vTIhYES8KrBqHFlH59vRyd365CXoB/aoNKVcP9UKPRb+lvGAf
PVUQDWSqasfvDI9fFg8n6Do5pBNW4cFakSdJSpS+gDfVsiU8CBrQV8LvSF4qIMoR
nyBX1tJiD8IK5uDEFdGnWNXjHtMrgbVi7MMpqplQcqop0Ag1PepApygAuZ2nIbPQ
rUB1GZ8NeXI7usOE1iKLvIzYOw7PX19B1kbEYwK7Jbqifi+YSy8DwGeRIFAPCrn6
BUJuvKEynMxHOJVLZICBcxy5osyQWjwDfEfbZaOIHZXyrx98SLU=
=uG3+
-----END PGP SIGNATURE-----
--=-=-=--
