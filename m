Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:53031 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab1IMSOI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 14:14:08 -0400
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        bfields@fieldses.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        LSM <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH -V6 00/26] New ACL format for better NFSv4 acl interoperability
In-Reply-To: Your message of "Mon, 12 Sep 2011 14:34:04 PDT."
             <4E6E7ACC.8040003@schaufler-ca.com>
From: Valdis.Kletnieks@vt.edu
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4E655049.6060507@schaufler-ca.com> <108028.1315442771@turing-police.cc.vt.edu>
            <4E6E7ACC.8040003@schaufler-ca.com>
Content-Type: multipart/signed; boundary="==_Exmh_1315937565_79123P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Date: Tue, 13 Sep 2011 14:12:45 -0400
Message-ID: <106565.1315937565@turing-police.cc.vt.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--==_Exmh_1315937565_79123P
Content-Type: text/plain; charset=us-ascii

(merging two replies)

On Mon, 12 Sep 2011 14:34:04 PDT, Casey Schaufler said:
> > Well, if it was done as an LSM, it would mean that if I wanted to build a
> > system where I have a few hundred terabytes of disk exported via Samba, and I
> > wanted Samba to save the CIFS permission ACL, I couldn't also run Selinux or
> > SMACK or anything like that - unless somebody actually snuck in the "LSMs are
> > stackable" patch while I wasn't looking?

> True, but not an acceptable argument for not doing it as an LSM.
> It is an argument in favor of LSM stacking, and after the Linux
> Security Summit this past week it seems only a matter of time before
> we have that. This could be the compelling use case that we've been
> missing for LSM stacking.

OK, I can certainly agree with that logic..

> So at this point, unless there is another reason why it can't be an
> LSM it should be an LSM.

Well, this issue still:

On Mon, 12 Sep 2011 18:43:51 EDT, "J. Bruce Fields" said:
> On Mon, Sep 12, 2011 at 03:38:24PM -0700, Casey Schaufler wrote:
> > POSIX ACLs require that the file permission bits change when
> > the ACL changes. This interaction violates the strict "additional
> > restriction" model of the LSM.
>
> Oh, OK.  Yes, rich ACLs are the same as POSIX ACLs in this respect.
> When you set an ACL the mode bits are reset to represent an "upper
> bound" on the permissions granted by the ACL.

Can we finess this detail by making the "set an ACL and make needed changes to
the mode bits" part of the VFS's responsibility as part of whatever syscall/
ioctl handling?  After all, the LSM doesn't get involved in the handling of
chmod() other than to say "yes/no this chmod can be issued" -  for instance,
the clearing of setUID/setGID bits when a file is written is done by each
individual filesystem. So there's certianly precident for doing the permission
tweaking in the VFS code. Then we can limit the LSM part to *applying* an
already existing ACL to permission checking.

Or should I go get some more caffeine? ;)


--==_Exmh_1315937565_79123P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOb50dcC3lWbTT17ARAgp2AJ47MqqG/Siu3rRJhkwivTpThkKKFQCgmYa+
UHRNSbg7AYkNRLBIh2BlVnA=
=mLgp
-----END PGP SIGNATURE-----

--==_Exmh_1315937565_79123P--
