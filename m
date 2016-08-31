Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:23148 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759680AbcHaNR4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 09:17:56 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Arnd Bergmann <arnd@arndb.de>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        "List Linux Network Devel Mailing" <netdev@vger.kernel.org>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.1: work around -Wmaybe-uninitialized warning
Date: Wed, 31 Aug 2016 13:17:48 +0000
Message-ID: <9F99A562-A4F6-457A-A78F-44BAC3B5734F@primarydata.com>
References: <20160831123911.3467676-1-arnd@arndb.de>
In-Reply-To: <20160831123911.3467676-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 31, 2016, at 08:39, Arnd Bergmann <arnd@arndb.de> wrote:
>=20
> A bugfix introduced a harmless gcc warning in nfs4_slot_seqid_in_use:
>=20
> fs/nfs/nfs4session.c:203:54: error: 'cur_seq' may be used uninitialized i=
n this function [-Werror=3Dmaybe-uninitialized]
>=20
> gcc is not smart enough to conclude that the IS_ERR/PTR_ERR pair
> results in a nonzero return value here. Using PTR_ERR_OR_ZERO()
> instead makes this clear to the compiler.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e09c978aae5b ("NFSv4.1: Fix Oopsable condition in server callback =
races")
> ---
> fs/nfs/nfs4session.c | 10 ++++++----
> 1 file changed, 6 insertions(+), 4 deletions(-)
>=20
> The patch that caused this just came in for v4.8-rc5. As the warning
> is now disabled by default and this is harmless, this can probably
> get queued for v4.9 instead.
>=20
> I mentioned earlier that I got the new warning for net-next, but
> failed to notice that it had come from mainline instead.
>=20
> diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
> index b62973045a3e..150c5a1879bf 100644
> --- a/fs/nfs/nfs4session.c
> +++ b/fs/nfs/nfs4session.c
> @@ -178,12 +178,14 @@ static int nfs4_slot_get_seqid(struct nfs4_slot_tab=
le  *tbl, u32 slotid,
> =09__must_hold(&tbl->slot_tbl_lock)
> {
> =09struct nfs4_slot *slot;
> +=09int ret;
>=20
> =09slot =3D nfs4_lookup_slot(tbl, slotid);
> -=09if (IS_ERR(slot))
> -=09=09return PTR_ERR(slot);
> -=09*seq_nr =3D slot->seq_nr;
> -=09return 0;
> +=09ret =3D PTR_ERR_OR_ZERO(slot);
> +=09if (!ret)
> +=09=09*seq_nr =3D slot->seq_nr;
> +
> +=09return ret;
> }
>=20

What version of gcc are you using? I=92m unable to reproduce with gcc 6.1.1=
..


