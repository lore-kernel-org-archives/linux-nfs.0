Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa3.hgst.iphmx.com ([216.71.153.141]:1457 "EHLO
        esa3.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388236AbeGXLDo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 07:03:44 -0400
From: Suresh Jayaraman <Suresh.Jayaraman@wdc.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
CC: Aditya Agnihotri <Aditya.Agnihotri@wdc.com>
Subject: Re: pNFS, multiple paths to Data Server not used by pNFS linux
 client.
Date: Tue, 24 Jul 2018 09:58:00 +0000
Message-ID: <BYAPR04MB4757AB8C13E8FA228B679D4083550@BYAPR04MB4757.namprd04.prod.outlook.com>
References: <SN6PR04MB4909ED311126ACD9341E339E82520@SN6PR04MB4909.namprd04.prod.outlook.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond et al,=0A=
=0A=
On 07/19/2018 12:39 PM, Aditya Agnihotri wrote:=0A=
> =0A=
> We are testing our pNFS server with linux client, when the server returns=
 multiple paths to a v4 DS via GETDEVINFO, we see that the client validated=
 the paths (does exchange id) but does not use the alternate paths in IO.=
=0A=
> Tracing the code path, it seems that when DS is a NFS v3 server, path is =
added, but for NFS v4 DS server, client setup function callback path fails =
to add.=0A=
=0A=
Is this observation that rpc_clnt_setup_test_and_add_xprt() doesn't call=0A=
rpc_xprt_switch_add_xprt() neither in the test function nor let=0A=
rpc_clnt_add_xprt() add the xprt correct? This seems to be limiting=0A=
Linux pNFS client from using multiple paths with Tegile/WD pNFS server.=0A=
=0A=
If yes, would you like a patch that attempts to fix this?=0A=
=0A=
=0A=
--=0A=
Suresh Jayaraman=0A=
