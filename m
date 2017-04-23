Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32862 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754408AbdDWWbT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Apr 2017 18:31:19 -0400
From: NeilBrown <neilb@suse.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 24 Apr 2017 08:31:11 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [bug report] sunrpc: don't check for failure from mempool_alloc()
In-Reply-To: <20170421195153.vzfthyjiaatc7t7k@mwanda>
References: <20170421195153.vzfthyjiaatc7t7k@mwanda>
Message-ID: <87shkyrc28.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 21 2017, Dan Carpenter wrote:

> Hello NeilBrown,
>
> The patch 62b2417e84ba: "sunrpc: don't check for failure from
> mempool_alloc()" from Apr 10, 2017, leads to the following static
> checker warning:
>
> 	fs/nfs/unlink.c:111 nfs_do_call_unlink()
> 	warn: 'task' isn't an ERR_PTR
>
> fs/nfs/unlink.c
>    106=20=20
>    107          NFS_PROTO(dir)->unlink_setup(&msg, dir);
>    108=20=20
>    109          task_setup_data.rpc_client =3D NFS_CLIENT(dir);
>    110          task =3D rpc_run_task(&task_setup_data);
>    111          if (!IS_ERR(task))
>    112                  rpc_put_task_async(task);
>
> This code is obviously harmless, but I get a ball of new warnings today.
> I haven't published this check because it has too many false positives
> so it only affects me.

Before the patch, rpc_run_task() would never fail, but a simple
inspection of the code suggested that it might return an error pointer.
After the patch, rpc_run_task() still cannot fail, and this is now
obvious from the code.

I'll put together a patch which removes all these pointless tests for
fail, in case Trond/Anna want to apply it.  If there is any credible
chance that we might one day change rpc_run_task() so that it could
fail, then we probably shouldn't apply it..

Thanks,
NeilBrown


>
> fs/nfs/unlink.c:111 nfs_do_call_unlink() warn: 'task' isn't an ERR_PTR
> fs/nfs/pagelist.c:602 nfs_initiate_pgio() warn: 'task' isn't an ERR_PTR
> fs/nfs/write.c:1627 nfs_initiate_commit() warn: 'task' isn't an ERR_PTR
> fs/nfs/nfs4proc.c:976 nfs4_call_sync_sequence() warn: 'task' isn't an ERR=
_PTR
> fs/nfs/nfs4proc.c:2023 _nfs4_proc_open_confirm() warn: 'task' isn't an ER=
R_PTR
> fs/nfs/nfs4proc.c:2190 nfs4_run_open_task() warn: 'task' isn't an ERR_PTR
> fs/nfs/nfs4proc.c:3208 nfs4_do_close() warn: 'task' isn't an ERR_PTR
> fs/nfs/nfs4proc.c:5475 nfs4_proc_setclientid() warn: 'task' isn't an ERR_=
PTR
> fs/nfs/nfs4proc.c:5694 _nfs4_proc_delegreturn() warn: 'task' isn't an ERR=
_PTR
> fs/nfs/nfs4proc.c:6193 _nfs4_do_setlk() warn: 'task' isn't an ERR_PTR
> fs/nfs/nfs4proc.c:7169 nfs4_proc_bind_one_conn_to_session() warn: 'task' =
isn't an ERR_PTR
> fs/nfs/nfs4proc.c:7527 _nfs4_proc_exchange_id() warn: 'task' isn't an ERR=
_PTR
> fs/nfs/nfs4proc.c:7758 nfs4_proc_get_lease_time() warn: 'task' isn't an E=
RR_PTR
> fs/nfs/nfs4proc.c:8233 nfs41_proc_reclaim_complete() warn: 'task' isn't a=
n ERR_PTR
> fs/nfs/nfs4proc.c:8467 nfs4_proc_layoutget() warn: 'task' isn't an ERR_PTR
> fs/nfs/nfs4proc.c:8585 nfs4_proc_layoutreturn() warn: 'task' isn't an ERR=
_PTR
> fs/nfs/nfs4proc.c:8732 nfs4_proc_layoutcommit() warn: 'task' isn't an ERR=
_PTR
> fs/nfs/nfs42proc.c:456 nfs42_proc_layoutstats_generic() warn: 'task' isn'=
t an ERR_PTR
> drivers/clk/x86/clk-pmc-atom.c:342 plt_clk_probe() warn: 'data->mclk_look=
up' isn't an ERR_PTR
> net/sunrpc/svc.c:1452 bc_svc_process() warn: 'task' isn't an ERR_PTR
> net/sunrpc/clnt.c:1083 rpc_call_sync() warn: 'task' isn't an ERR_PTR
> net/sunrpc/clnt.c:1113 rpc_call_async() warn: 'task' isn't an ERR_PTR
> net/sunrpc/clnt.c:2585 rpc_clnt_test_and_add_xprt() warn: 'task' isn't an=
 ERR_PTR
> net/sunrpc/clnt.c:2632 rpc_clnt_setup_test_and_add_xprt() warn: 'task' is=
n't an ERR_PTR
> net/sunrpc/rpcb_clnt.c:784 rpcb_getport_async() warn: 'child' isn't an ER=
R_PTR
>
> regards,
> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj9Ky8ACgkQOeye3VZi
gbkY1Q//YU2GcnEFgw0R7TGOsU9h4UeDNMzPJ/hh1UcoOwWmOi8LRsgs6ZFmZTd/
0QGeWXy9hqtT9mrHx6C6ujtCeuk8gn9L59xEaW5Xuy3iKPBb7LDvYLF+etltXhQi
joS3JypM97KBmESs/JeGCbR57uO14j/a/36zyNxLGBwUFWAKTwrDKCzT25YnN5RD
6c2CcoRR63uuZY1igKGshrMoVB9KRFDpFmJkjTIQIVqCijI6wTBhAYVS9/kyfX2U
/njENLCK6Ee2MGVJA/CPthPfHG2/9+R0BviBiDEReQ+CU367g6RcnS8OSX7IlLsf
YvHjhhkz81+mpNNi39h82Kj8AHZ+G9+rIoEdjunGzRTviOK24YpeUCdY1UCBvW/L
E8aqlzy5QACyQkWuo821oOexxpdQUUIV2mSzBtncMPutoVmOARaBmuMad9/t3vrJ
jHPQsR8ZPQnREvEM5Cc8E7Yh5VUQU24jz/wQYnYOFONgPEyqxzf8JHPXLu2nQqpy
o4KR8K+wPOmR+Cr/WqB2u+IftFrLh1VnXzoY4Lgxz36rJ9JtBfy0y7hfpUPR/Bbn
pMgZV/eJaCfa+8FYpSp/kpP9SPPPuxhQ//i7iWXfQhIpR/zZXPdSpRmItd/zpxzh
iG9OjEt9LyXRH3InRoMsEX/rE+hPx8n7flBtYC6TllZVgrsMGtc=
=azJq
-----END PGP SIGNATURE-----
--=-=-=--
