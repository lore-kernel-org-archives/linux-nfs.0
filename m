From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH RFC] nfs: initialize timeout variable in
	nfs4_proc_setclientid_confirm
Date: Tue, 24 Jun 2008 14:50:59 -0400
Message-ID: <1214333459.7156.39.camel@localhost>
References: <48612E25.8050405@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42136 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbYFXSvE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2008 14:51:04 -0400
In-Reply-To: <48612E25.8050405@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-24 at 20:25 +0300, Benny Halevy wrote:
> gcc (4.3.0) rightfully warns about this:
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/nfs4proc.c: I=
n function =E2=80=98nfs4_proc_setclientid_confirm=E2=80=99:
> /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/nfs4proc.c:29=
36: warning: =E2=80=98timeout=E2=80=99 may be used uninitialized in thi=
s function
>=20
> nfs4_delay that's passed a pointer to 'timeout' is looking at its val=
ue
> and sets it up to some value in the range: NFS4_POLL_RETRY_MIN..NFS4_=
POLL_RETRY_MAX
> 	if (*timeout <=3D 0)
> 		*timeout =3D NFS4_POLL_RETRY_MIN;
> 	if (*timeout > NFS4_POLL_RETRY_MAX)
> 		*timeout =3D NFS4_POLL_RETRY_MAX;
>=20
> Therefore it will end up set to some sane, though rather indeterminis=
tic, value.
>=20
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>=20
> Trond, this patch merely initializes timeout to 0 which will
> result in it set eventually to NFS4_POLL_RETRY_MIN.
> Is this appropriate?

ACK. Since the existing will always return sane values, and nobody has
complained yet, I'll queue this up for 2.6.27 rather than pushing it as
a hotfix.

Thanks!
  Trond

