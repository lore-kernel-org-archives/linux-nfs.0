Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49038 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726053AbeHNLtj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Aug 2018 07:49:39 -0400
From: NeilBrown <neilb@suse.com>
To: Bruce Fields <bfields@fieldses.org>
Date: Tue, 14 Aug 2018 19:03:14 +1000
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
In-Reply-To: <878t5bqgx0.fsf@notabene.neil.brown.name>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com> <20160321144349.GA12804@lst.de> <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com> <874lg3roua.fsf@notabene.neil.brown.name> <20180810170027.GF7906@fieldses.org> <20180810170312.GG7906@fieldses.org> <87d0uor11r.fsf@notabene.neil.brown.name> <20180812132100.GL7906@fieldses.org> <878t5bqgx0.fsf@notabene.neil.brown.name>
Message-ID: <87ftzhb9rh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Aug 13 2018, NeilBrown wrote:

> On Sun, Aug 12 2018, Bruce Fields wrote:
>> OK, so not too important.  Still, it sounds like
>> inode_owner_or_capable() is something people expect to work for any
>> filesystem, so I wonder if there's a way to do that.  Or at least
>> disable it.
>
> We could add a new flag - MAY_OWN (or something) - to the flags
> recognised by inode_permission() and i_op->permission().
>
> If ->permission isn't set, inode_permission() uses
> inode_owner_or_capable().
> If it is, it gets to call that, or do whatever is appropriate.
>
> Is this flag the same as NFS_MAY_OWNER_OVERRIDE or not....??
>

Pursuing this thought...
  NFSD_MAY_OWNER_OVERRIDE means "an operation is requested which
   may always be performed by the owner of the file, even if they
   don't have explicit permission via DAC setting."

I think this is a reasonable description of how inode_owner_or_capable()
is used.  It is sometimes used on its own, where there is no permission
but that is relevant such as O_NOATIME or set_posix_acl(), or is used
as a precursor to and inode_permission() check, as in notify_change().

The biggest difference is that NFSD_MAY_OWNER_OVERRIDE does have the
"or_capable".
As nfsd drops CAP_FOWNER, and the extra test won't hurt it.

So I now think that a good solution to this problem would be to hoist
NFSD_MAY_OWNER_OVERRIDE into the VFS and change inode_permission() and
various i_op->permission functions to handle it.

All we need is a good name....
  MAY_BY_OWNER  ???
  MAY_IF_OWNER
  MAY_BE_OWNER ???

MAY_READ means "may I please read this file".  The flag needs to say
"may I act as the owner of this file", so
  MAY_ACT_AS_OWNER ????

Thought?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAltymtIACgkQOeye3VZi
gbnG3g/+LNlIIfRL5CtRzVmf/ojtvk+idx6RRPG5XY0l1IaRpwxlGkw3O+hduZ0D
w+L3nwAxChHiGYnlGUAreqeZm+32DQOUZrfkhxPhGCQ34BFzx63Wat7O/FkS/EvF
t8BS1nQMMYplSnFx6tK1aRcumrglPQ02H7V4i1gx4Ww5nRJ9EcnpnJnd87vqSqEs
s7qu9c0lHMxC7Xtcbovwihy7xN91O7UYjaM1ViG60a9NPslNaPdrM1YZFsoH6/Nd
HmeWWTF+tVh0SuByBldu7c+kkb9684X0EgZxfT3xhJCDATj/mpVCQJtZnF2/ECW/
mmjzxYkUfVspMJ8SPAKaaNKpzFn21ARbxOhqetLNKa2xGshUyy3AF/kPjByDb4AR
yGpXmdBlj1/DSzkcfigQaPZVfiuVE5gqQGc+nW/X57Vbc/cwDs3UWSzif2DlgkcA
KxZ1HYM6lqKgWTd6QPfTaHYsXg3TvSBzcp/S/3c5pNSEoU9OQjIDX1SKa1ubqlyE
evURakL+iHg16mJcau/MH9fEfib3g2gmEwgh2gty2mRzrp14DGZW0JKTezGUx45J
e/rnS1FBhCW+fKiLYeHgkl9e0tNJyp1ghGddA0vlyMtMv3xSlmaTYoaeA0Y6aoOy
ffdsjyQcasDUnlEJnVmKHjO0FD2oSN3EyvuGnp8pdPta1TXaO/U=
=tjxs
-----END PGP SIGNATURE-----
--=-=-=--
