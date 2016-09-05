Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:24924 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932234AbcIER7S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 13:59:18 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "J. R. Okajima" <hooanon05g@gmail.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: 4.8-rcN nfs, access(W_OK) on an immutable inode
Date: Mon, 5 Sep 2016 17:59:08 +0000
Message-ID: <D2C9D52A-1C3D-491E-9C90-205B2B85F284@primarydata.com>
References: <3647.1472877116@jrobl> <24930.1473095997@jrobl>
In-Reply-To: <24930.1473095997@jrobl>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 5, 2016, at 13:19, J. R. Okajima <hooanon05g@gmail.com> wrote:
>=20
>=20
> Hello again,
>=20
> linux-v4.8-rcN has a commit
> =09337684a 2016-08-07 fs: return EPERM on immutable inode
>=20
> I am afraid NFS should follow the same behaviour. In other words,
> fs/nfs/dir.c:nfs_do_access() should return -EPERM when MAY_WRITE on an
> immutable inode. Currently it returns EACCES.
>=20

The NFS protocol has no way to convey to the client that the inode is label=
ed as immutable on the server. The NFSv4.1 =93retention_hold=94 mechanism d=
escribed in RFC5661 comes close, and could possibly be used, but it is not =
implemented for now.

Note also that file immutability is not a POSIX concept, and EPERM is conse=
quently not listed as one of the POSIX sanctioned return values for access(=
): http://pubs.opengroup.org/onlinepubs/9699919799/functions/access.html

Cheers
  Trond

