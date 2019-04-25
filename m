Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50594C43219
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 21:08:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F227206A3
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 21:08:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="XW6hidJj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729647AbfDYVIb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 17:08:31 -0400
Received: from mail-wm1-f65.google.com ([209.85.128.65]:54880 "EHLO
        mail-wm1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727083AbfDYVIb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2019 17:08:31 -0400
Received: by mail-wm1-f65.google.com with SMTP id c1so974521wml.4
        for <linux-nfs@vger.kernel.org>; Thu, 25 Apr 2019 14:08:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=jyIE8DjMzb5dKV+Qlzd0b+pwTR+kKu4UYlXf4EUaRsE=;
        b=XW6hidJjLKxmUfe7/uIS1elgY1upNnlqx/Q181ejhYWj1UqKAkRXZSVm/LSMakEtpX
         DynHhnttarwHjyZZ9hlfuZSoAlrs6cXmUp/mX5xILcvcmZY3nSEQ9170lxXqDsHvIFoa
         NYo04tyHwUVmUJ9uLEBK62DcY/5pkvGwge3Nqff4jmJ0sp799ZdlOnIsaeUCXoBJEzbP
         nuHOkVX2ucij+5A/2Z1Ju1l5/aqXSR34KWkXHyqLk/qprEoBc17e/o5+4sO9/xZb1LgP
         R4CgY6zJ0O8wZygvNy2hFwqgGUkpQ2u3IxlZKJc3jJodE4+8ggelUTJ29bcqSR3zEOtf
         BkAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:message-id:mime-version:subject:date
         :in-reply-to:cc:to:references;
        bh=jyIE8DjMzb5dKV+Qlzd0b+pwTR+kKu4UYlXf4EUaRsE=;
        b=kFbLWXUpjSyc0dyp82QUAxXPWpGqitIzkqYNg9ZEpZIEshd98on5bnNxmVAHgMbcvk
         X4ARFr/fvG8J69HdzyXj+C4ZLut0QMPh9HDmFBhOBijLwmt0TM7d3t7CAeli+fZdCMXX
         rXYiATxCq7p2dzpqX73Efz0u5or98HHmzoJYqLQ6wuBfGXCE5chZyZz9BVheI5m20B0k
         drJTdXPkjec6oUNrji/xcD11mtg9DER/BY0yemPkEDBTmnO1HrWC1Md+3YDemLXS73HV
         JgUNDdq4L7q51t/cNuNRyO7nEvUByV73ulcuHGkZGSUXs2gxyhaMjzvTsch1DM6glkNy
         LdZw==
X-Gm-Message-State: APjAAAWiRC0OJSf3sN2/otgsSpqxGvsM0PR9bVMKYjIKTVE4sxpmMlgQ
        rEFLjPrgwiZN6XgbjBeZG1Rwiw==
X-Google-Smtp-Source: APXvYqzkerfEEI2t55R8z/5YlmYMXAmqxJPnt2hHMGLoMYZKTSuzdj7nhBtAm3p7rrGMDT6AJFZKZw==
X-Received: by 2002:a7b:ce09:: with SMTP id m9mr4586697wmc.133.1556226508697;
        Thu, 25 Apr 2019 14:08:28 -0700 (PDT)
Received: from surfer-172-29-5-61-hotspot.internet-for-guests.com ([185.37.136.130])
        by smtp.gmail.com with ESMTPSA id a10sm13316497wro.67.2019.04.25.14.08.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:08:28 -0700 (PDT)
From:   Andreas Dilger <adilger@dilger.ca>
Message-Id: <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_BEB8AC4B-AEE9-448D-A1A6-6B3A1B764AEF";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
Date:   Thu, 25 Apr 2019 23:08:25 +0200
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>, NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
X-Mailer: Apple Mail (2.3273)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--Apple-Mail=_BEB8AC4B-AEE9-448D-A1A6-6B3A1B764AEF
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 25, 2019, at 4:04 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>=20
> From: "J. Bruce Fields" <bfields@redhat.com>
>=20
> The following patches expose information about NFSv4 opens held by =
knfsd
> on behalf of NFSv4 clients.  Those are currently invisible to =
userspace,
> unlike locks (/proc/locks) and local proccesses' opens (/proc/<pid>/).
>=20
> The approach is to add a new directory /proc/fs/nfsd/clients/ with
> subdirectories for each active NFSv4 client.  Each subdirectory has an
> "info" file with some basic information to help identify the client =
and
> an "opens" directory that lists the opens held by that client.
>=20
> I got it working by cobbling together some poorly-understood code I
> found in libfs, rpc_pipefs and elsewhere.  If anyone wants to wade in
> and tell me what I've got wrong, they're more than welcome, but at =
this
> stage I'm more curious for feedback on the interface.

Is this in procfs, sysfs, or a separate NFSD-specific filesystem?
My understanding is that "complex" files are verboten in procfs and =
sysfs?
We've been going through a lengthy process to move files out of procfs
into sysfs and debugfs as a result (while trying to maintain some kind =
of
compatibility in the user tools), but if it is possible to use a =
separate
filesystem to hold all of the stats/parameters I'd much rather do that
than use debugfs (which has become root-access-only in newer kernels).

Cheers, Andreas

> I'm also cc'ing people responsible for lsof and util-linux in case =
they
> have any opinions.
>=20
> Currently these pseudofiles look like:
>=20
>  # find /proc/fs/nfsd/clients -type f|xargs tail
>  =3D=3D> /proc/fs/nfsd/clients/3741/opens <=3D=3D
>  5cc0cd36/6debfb50/00000001/00000001	rw	--	fd:10:13649	=
'open id:\x00\x00\x00&\x00\x00\x00\x00\x00\x00\x0b\xb7\x89%\xfc\xef'
>  5cc0cd36/6debfb50/00000003/00000001	r-	--	fd:10:13650	=
'open id:\x00\x00\x00&\x00\x00\x00\x00\x00\x00\x0b\xb7\x89%\xfc\xef'
>=20
>  =3D=3D> /proc/fs/nfsd/clients/3741/info <=3D=3D
>  clientid: 6debfb505cc0cd36
>  address: 192.168.122.36:0
>  name: Linux NFSv4.2 test2.fieldses.org
>  minor version: 2
>=20
> Each line of the "opens" file is tab-delimited and describes one open,
> and the fields are stateid, open access bits, deny bits,
> major:minor:ino, and open owner.
>=20
> So, some random questions:
>=20
> 	- I just copied the major:minor:ino thing from /proc/locks, I
> 	  suspect we would have picked something different to identify
> 	  inodes if /proc/locks were done now.  (Mount id and inode?
> 	  Something else?)
>=20
> 	- The open owner is just an opaque blob of binary data, but
> 	  clients may choose to include some useful asci-encoded
> 	  information, so I'm formatting them as strings with non-ascii
> 	  stuff escaped.  For example, pynfs usually uses the name of
> 	  the test as the open owner.  But as you see above, the ascii
> 	  content of the Linux client's open owners is less useful.
> 	  Also, there's no way I know of to map them back to a file
> 	  description or process or anything else useful on the client,
> 	  so perhaps they're of limited interest.
>=20
> 	- I'm not sure about the stateid either.  I did think it might
> 	  be useful just as a unique identifier for each line.
> 	  (Actually for that it'd be enough to take just the third of
> 	  those four numbers making up the stateid--maybe that would be
> 	  better.)
>=20
> In the "info" file, the "name" line is the client identifier/client
> owner provided by the client, which (like the stateowner) is just =
opaque
> binary data, though as you can see here the Linux client is providing =
a
> readable ascii string.
>=20
> There's probably a lot more we could add to that info file eventually.
>=20
> Other stuff to add next:
>=20
> 	- nfsd/clients/#/kill that you can write to to revoke all a
> 	  client's state if it's wedged somehow.
> 	- lists of locks and delegations; lower priority since most of
> 	  that information is already in /proc/locks.
>=20
> --b.
>=20
> J. Bruce Fields (10):
>  nfsd: persist nfsd filesystem across mounts
>  nfsd: rename cl_refcount
>  nfsd4: use reference count to free client
>  nfsd: add nfsd/clients directory
>  nfsd: make client/ directory names small ints
>  rpc: replace rpc_filelist by tree_descr
>  nfsd4: add a client info file
>  nfsd4: add file to display list of client's opens
>  nfsd: expose some more information about NFSv4 opens
>  nfsd: add more information to client info file
>=20
> fs/nfsd/netns.h                |   6 +
> fs/nfsd/nfs4state.c            | 228 ++++++++++++++++++++++++++++++---
> fs/nfsd/nfsctl.c               | 225 +++++++++++++++++++++++++++++++-
> fs/nfsd/nfsd.h                 |  11 ++
> fs/nfsd/state.h                |   9 +-
> fs/seq_file.c                  |  17 +++
> include/linux/seq_file.h       |   2 +
> include/linux/string_helpers.h |   1 +
> lib/string_helpers.c           |   5 +-
> net/sunrpc/rpc_pipe.c          |  37 ++----
> 10 files changed, 491 insertions(+), 50 deletions(-)
>=20
> --
> 2.20.1
>=20


Cheers, Andreas






--Apple-Mail=_BEB8AC4B-AEE9-448D-A1A6-6B3A1B764AEF
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAlzCIcoACgkQcqXauRfM
H+DOVA//dAdwmaRQxrUyATPuhRSxQoXGxe3lIbP+NpkKDzLMQofmm+QN3PdVrTYg
KIr0oEdNc8ZC1+zh767wMRZJ/q9XRT3zqkU6QQQIoqq/ByKEyX+SPakNqZNc10Er
sJ1OwdypGlMwJO9fr6uzY28uANG90PJsy7PQ0K3+Q4hsxOsMEp+0EG4k612usi9K
p/H7r3DaFfdJblsKB0AKliN51RpGGIelRu264KDrAFvosLP/pwL7jfCCJhB25KC7
YlPzV+RUKy+ioS58Bx6GtO8TR1Hy+VUC704mJ/8NDnoTQaClyVtgkhkTyitukF6T
s+HhwjSlt2wECLTYmCY5Ws2lMT6g6//AkdBm/CAha7iFziHaXxpMR1H7Uqs8jzkc
kkQpd8bEpKf5FxAnZMsHv2ygHP7RDHmyVCQeXf8k3m/cg0t5fgPI7dwRJmBdUL1W
WtkMo5N/N2ry51RiBoEHLKDdw8LDrywIQ6yK5z0MbUSWLnMSsqBt/cbbifW0+GEB
ofk66BvAu6rcGHdnWzPYFLoorGsAbWcelp9etnBBc4yB8tusU2LJgHqmsBZDCq0I
Wx+4JvhCswMWjZXtjoVc3uCNth8AB9HjYho7OBRrCPad8ueBPMdzj4OkqW4RBCBu
yZHaVqWGgI3YaFYVa3HxxMcr4M/DOs47s754CxoVLM8mYw2iqds=
=Gamh
-----END PGP SIGNATURE-----

--Apple-Mail=_BEB8AC4B-AEE9-448D-A1A6-6B3A1B764AEF--
