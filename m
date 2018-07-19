Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa5.hgst.iphmx.com ([216.71.153.144]:24077 "EHLO
        esa5.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726672AbeGSHul (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jul 2018 03:50:41 -0400
From: Aditya Agnihotri <Aditya.Agnihotri@wdc.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: pNFS, multiple paths to Data Server not used by pNFS linux client.
Date: Thu, 19 Jul 2018 07:09:01 +0000
Message-ID: <SN6PR04MB4909ED311126ACD9341E339E82520@SN6PR04MB4909.namprd04.prod.outlook.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

We are testing our pNFS server with linux client, when the server returns m=
ultiple paths to a v4 DS via GETDEVINFO, we see that the client validated t=
he paths (does exchange id) but does not use the alternate paths in IO.
Tracing the code path, it seems that when DS is a NFS v3 server, path is ad=
ded, but for NFS v4 DS server, client setup function callback path fails to=
 add.

Forcing the paths to be added seems to fix the issue, so we think there mig=
ht be a bug.

We see that when data server is v3, it's setup function does call
rpc_xprt_switch_add_xprt

=20
via , static const struct rpc_call_ops rpc_cb_add_xprt_call_ops =3D {
        .rpc_call_done =3D rpc_cb_add_xprt_done,
        .rpc_release =3D rpc_cb_add_xprt_release,
};

=20
nfs4_pnfs_ds_connect->_nfs4_pnfs_v3_ds_connect->
rpc_clnt_add_xprt->
rpc_clnt_test_and_add_xprt->
rpc_cb_add_xprt_done->rpc_xprt_switch_add_xprt

but v4 add xprt does not, so a connection for multipathing gets validated f=
or v4, but never added.

nfs4_pnfs_ds_connect->nfs4_pnfs_ds_connect->
rpc_clnt_add_xprt->rpc_clnt_setup_test_and_add_xprt returns error(1) but ne=
ver adds.

Thanks
-Aditya




