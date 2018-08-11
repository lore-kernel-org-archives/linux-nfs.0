Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44140 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727229AbeHLBDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 11 Aug 2018 21:03:49 -0400
From: NeilBrown <neilb@suse.com>
To: Bruce Fields <bfields@fieldses.org>
Date: Sun, 12 Aug 2018 08:28:00 +1000
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <20180810170312.GG7906@fieldses.org>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com> <20160321144349.GA12804@lst.de> <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com> <874lg3roua.fsf@notabene.neil.brown.name> <20180810170027.GF7906@fieldses.org> <20180810170312.GG7906@fieldses.org>
Message-ID: <87d0uor11r.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 10 2018, Bruce Fields wrote:

> On Fri, Aug 10, 2018 at 01:00:27PM -0400, Bruce Fields wrote:
>> On Fri, Aug 10, 2018 at 11:29:33AM +1000, NeilBrown wrote:
>> > On Mon, Mar 21 2016, Nelson Elhage wrote:
>> >=20
>> > > That's correct. The other detail that seems to be important is that
>> > > the user making the call must be different from the user owning the
>> > > file. We've also been using user remapping on the server, so that
>> > > non-xattr calls succeed in that configuration.
>> > >
>> > > The reproducer James added in the bugzilla is:
>> > >
>> > > (on machine with IP address 10.1.1.1)
>> > > sudo mkdir /nfs_test
>> > > sudo useradd -u 10000 test_user
>> > > sudo chown test_user /nfs_test
>> > > echo "/nfs_test 10.1.1.2(rw,all_squash,anonuid=3D10000)" | sudo tee =
-a
>> > > /etc/exports
>> > > sudo exportfs -a
>> > >
>> > > (on machine with IP address 10.1.1.2)
>> > > sudo mkdir /nfs_test
>> > > sudo mount -t nfs -o vers=3D3,noacl 10.1.1.1:/nfs_test /nfs_test
>> > > touch /nfs_test/foo
>> > > install -m 755 /nfs_test/foo /nfs_test/bar
>> >=20
>> > Did anything ever happen about this?
>> > I have a customer with a similar problem (in 4.4) but I cannot see any
>> > evidence of fixes landing in mainline.
>> >=20
>> > Problem happens with you have uid mapping on the server
>> > (e.g. anonuid=3D10000 as above) and a user with a different uid on the
>> > client attempts setacl on a file with that user.
>> > As anon is mapped to the owner of the file, setacl should be allowed.
>> > However set_posix_acl() calls inode_owner_or_capable() which checks if
>> > the client-side uid matches the visible inode->i_uid - they don't.
>> >=20
>> > Testing i_uid on the client is always incorrect for permission checking
>> > with NFS - the client should always ask the server, either with ACCESS
>> > or, in this case, by simply attempting the operation.
>> >=20
>> > Any suggestions how best to fix this?
>> > - We could move the responsibility for permission checking into
>> >   i_op->set_acl, but that would be a large change and might make it too
>> >   easy for other filesystems to get it wrong.
>> > - we could have some sort of flag asking set_posix_acl(), but that's
>> >   rather clumsy.... maybe if i_op->set_acl_check_perm use that without
>> >   testing ownership first??
>> > - we could copy
>> >     posic_acl_xattr_{get,set,list} into nfs together with functions
>> >     they call, modify set_posix_acl() to not test ownership,
>> >     and provide a local 'struct xattr_handler' structure for NFS.
>> >=20
>> > I don't really like any of those suggestions.  Can someone else do any
>> > better?
>>=20
>> Do we have important callers of inode_owner_or_capable() in the vfs (as
>> opposed to in individual filesystems), and do any of them pose a similar
>> problem for network filesystems?
>
> do_linkat()->may_linkat() looks kinda suspicious to me.  Or what about
> the O_NOATIME check in map_open()?  Just engaging in dumb grepping
> here....
>
> --b.

NOATIME, both in open and fcntl, is rejected on NFS.  This seems valid
as there is no way in the protocol to ask the server to no update the
atime.

Others I found we just short-cuts to avoid calling i_op->permission() if
the caller was an owner.  I don't *think* that would affect NFS much
... though if an owner didn't have write permission, some things might
be incorrectly forbidden.  Maybe.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAltvYvAACgkQOeye3VZi
gbm9FQ/8CC+bWAWcihsiGXIxsS1DLmsNNB86ILycWB9WQCYND6DquW9rYPvRwEal
N1y2fnU6wYuvhNnaZkyT0fWaVFU/8/X5pFZmJSgA+67QE/fh7154QXp/0pVoAS+K
HWXwP6VnFQoAI9IjT2bHDYi5FpW/0qeV3BlLuM3JppY7ShZ9I3botLhVURTGqTh8
AW9rhD0NU49BDSWOuP7OtcmYzymca6jR7V/E+9/XbAxstOs/PWvAh+xy9/100cFu
1AGfDSPw7lPDs7zYTCKMhMurROViqrA3OXwjfzdwTuWBdmZ/yOhHLuL42LLwuIw/
Fmayflf9tueRTfMUF2zq6X6eyOJRN13VL3SDG9bwq4oAoPqJvJaGx2RDk9q4P+5L
ploVyGSUZDzsiZpoDpzhK+BFgGyYheE3fTHOaWx2bTF0fOQssWO5YB21O6ZRT7ZO
4MAg1nnFq5vMqS53jY7U+M57pbSlLY3tIVYls5jiyAWFZzT95WLAtzPG7l1B1Xth
PfwmwY6jzrnxBNRKNDlvn1EJQf9cKX3kXhOkXY4H0ifzSKbWS+QdJnxcMdSlWjav
rIJ/v8XwCWveXgau9hBFiM9NbdFDB1v6f/ma+mWoWlRsLg/pLR06OzXCvB012XgT
9D6rBgdt+ot4SrOZjUBf/At+85Mp3BJpXkUMbAPlmgippZj7t64=
=zDey
-----END PGP SIGNATURE-----
--=-=-=--
