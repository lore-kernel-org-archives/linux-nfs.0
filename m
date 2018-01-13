Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:49556 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965201AbeAMCP6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jan 2018 21:15:58 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] nfsd: Detect unhashed stids in nfsd4_verify_open_stid()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180112224230.129322-1-trond.myklebust@primarydata.com>
Date: Fri, 12 Jan 2018 21:15:46 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3D728866-A30E-420D-9001-F4B212432C36@oracle.com>
References: <20180112224230.129322-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Bruce Fields <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 12, 2018, at 5:42 PM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:
>=20
> The state of the stid is guaranteed by 2 locks:
> - The nfs4_client 'cl_lock' spinlock
> - The nfs4_ol_stateid 'st_mutex' mutex
>=20
> so it is quite possible for the stid to be unhashed after lookup,
> but before calling nfsd4_lock_ol_stateid(). So we do need to check
> for a zero value for 'sc_type' in nfsd4_verify_open_stid().
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Three successful passes of the git regression suite on NFSv4.1
Three successful passes of xfstests on NFSv4.1

Tested-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> fs/nfsd/nfs4state.c | 1 +
> 1 file changed, 1 insertion(+)
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 8d53d29161f5..b5bda115f6a9 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3591,6 +3591,7 @@ nfsd4_verify_open_stid(struct nfs4_stid *s)
> 	switch (s->sc_type) {
> 	default:
> 		break;
> +	case 0:
> 	case NFS4_CLOSED_STID:
> 	case NFS4_CLOSED_DELEG_STID:
> 		ret =3D nfserr_bad_stateid;
> --=20
> 2.14.3
>=20

--
Chuck Lever



