Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga14.intel.com ([143.182.124.37]:32844 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698Ab2FKJOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jun 2012 05:14:47 -0400
Date: Mon, 11 Jun 2012 12:16:00 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marco Stornelli <marco.stornelli@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Boaz Harrosh <bharrosh@panasas.com>,
        Tao Ma <boyu.mt@taobao.com>, Nick Piggin <npiggin@kernel.dk>,
        "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@telemann.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-ID: <20120611091600.GA1122@otc-wbsnb-06>
References: <20120608221446.GA18250@otc-wbsnb-06>
 <20120608152550.258d6a30.akpm@linux-foundation.org>
 <20120608222734.GT30000@ZenIV.linux.org.uk>
 <20120608153120.b722d7c3.akpm@linux-foundation.org>
 <20120608233127.GB18981@otc-wbsnb-06>
 <20120608163751.7a8ec2bc.akpm@linux-foundation.org>
 <CA+55aFw5k3daxeoZb9H1HGcOCWjPF+d7inSbf0QHmG-atp4reQ@mail.gmail.com>
 <20120608172842.9826b5cd.akpm@linux-foundation.org>
 <4FD2F5F4.1000106@gmail.com>
 <20120609002557.b8aba759.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
In-Reply-To: <20120609002557.b8aba759.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 09, 2012 at 12:25:57AM -0700, Andrew Morton wrote:
> And...  it seems that I misread what's going on.  The individual
> filesystems are doing the rcu freeing of their inodes, so it is
> appropriate that they also call rcu_barrier() prior to running
> kmem_cache_free().  Which is what Kirill's patch does.  oops.

Ack? ;)

--=20
 Kirill A. Shutemov

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP1bdQAAoJEAd+omnVudOMOWIP/0ggxQY/gopg5nzCYdokfLxR
gz+eQJznRY+O6tbDMn0QyMJNfwsqKWUKVPxVmBnzrXv2YXiU2s1pdeWcUrkhkGzo
t+dSzoQYx3IsVY23ViQvCojLacfFODIUvb/fu7h+ZOFN3xkCB9VW7Do7y4JwflUV
2kEzQc+a6BU660CPnkDsGVLQTj9gw6XSmKazzbHkLg6wAr4IyyKAq7MPvLQfocIo
ZF9oqOTKx+2K0+YaupJJRzxPPPxOCXUzxPDjbJIAOJHJQ2DtJy2WEME5V4wS9R7K
+9ldJwDN4uu+IpWGVMJFNXCkRQk6UfmKgBLrVv+32Y2+B2VebXeaEj3QECpmqqcG
vm3vLoQB0TITfjtGTSqojE7WjTJl61jarsFzXEY3bvwdJ3h1XHeUhK5pbBiRVcu2
v7RkgZH04E5Y+3/FGJVvxWRy+GJafI7ip+G8Rdl2r7aNmuyjmqtkdmBms/VS53Pp
Oc1bDv+wmVwJjPJzT6z/7gE/A8LHvizvZfvt8ttS2WbWHhTuObLvtSnNd03ayhWu
ROYpfE7qQ6CTrcGilpOLg9+N5wZOrT1mxn4s8h9d2+mkUdLHkudMFOoM/aTUyR0r
A+Jq0iCfFYO6+SdhRo4zbecLVf0aihZ+pdOHQJ428Cguf28QPHusRiPlaYYTrsHD
8zzLHxfwcftJ4IqVR7K4
=IpC+
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
