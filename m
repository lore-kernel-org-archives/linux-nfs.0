Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:63558 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab3EFKdM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 06:33:12 -0400
Received: by mail-wi0-f169.google.com with SMTP id h11so2533990wiv.2
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 03:33:11 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 6 May 2013 16:03:10 +0530
Message-ID: <CADDb1s3j7j7McdUL1YxVAVGPNHBEj1qTUA62ve789Z0Pii9eyg@mail.gmail.com>
Subject: Continuous Retry of NFS Query
From: Amit Sahrawat <amit.sahrawat83@gmail.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        bfields@fieldses.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I am facing a very abnormal situation while using NFS mount, when I
see using RPC debug logs I can see repeat requests for FSINFO.
Even though my network connection is working fine.

Setup:
2 Targets connected back-to-back
1st Target: Kernel version 2.6.35 (NFS Server)
2nd target: Kernel version 3.0.2 (NFS Client)

In between the logs I observed this message:
"nfs: server 10.123.175.123 not responding, still trying"
on my NFS Client.

At times mount is stucked resulting in HUNG like situation.

Example Logs:
[ 22.714086] RPC: 1 __rpc_execute, mount.nfs, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100005
[ 22.727970] RPC: 1 __rpc_execute, mount.nfs, (null), status = 0
[ 22.740855] RPC: 1 xprt_complete_rqst, mount.nfs, p_name: (null),
tk_status: 0, tk_timeout: 0 ms, prog: 100005, (24 bytes received)
[ 22.741884] RPC: 1 __rpc_execute, mount.nfs, (null) return 0, status 0
[ 22.743268] RPC: 2 __rpc_execute, mount.nfs, p_name: MOUNT,
tk_status: 0, tk_timeout: 3000 ms, prog: 100005
[ 22.745915] RPC: 2 xprt_complete_rqst, NetworkDeviceMo, p_name:
MOUNT, tk_status: 0, tk_timeout: 3000 ms, prog: 100005, (60 bytes
received)
[ 22.746140] RPC: 2 __rpc_execute, mount.nfs, MOUNT, status = 0
[ 22.746254] RPC: 2 __rpc_execute, mount.nfs, MOUNT return 0, status 0
[ 22.747939] RPC: 3 __rpc_execute, mount.nfs, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.752891] RPC: 4 xprt_complete_rqst, HAND_Thread, p_name: GETPORT,
tk_status: 0, tk_timeout: 3000 ms, prog: 100000, (28 bytes received)
[ 22.758909] RPC: 4 __rpc_execute, kworker/0:2, GETPORT return 0, status 0
[ 22.759513] RPC: 3 __rpc_execute, mount.nfs, (null), status = 0
[ 22.760123] RPC: 3 __rpc_execute, mount.nfs, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.762744] RPC: 3 __rpc_execute, mount.nfs, (null), status = 0
[ 22.763823] RPC: 3 __rpc_execute, mount.nfs, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.767715] RPC: 3 xprt_complete_rqst, swapper, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (24 bytes received)
[ 22.768048] RPC: 3 __rpc_execute, mount.nfs, (null), status = 0
[ 22.768129] RPC: 3 __rpc_execute, mount.nfs, (null) return 0, status 0
[ 22.769736] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.778448] RPC: 5 xprt_complete_rqst, swapper, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (80 bytes received)
[ 22.778651] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 22.778695] RPC: 5 __rpc_execute, mount.nfs, FSINFO return 0, status 0
[ 22.778828] RPC: 6 __rpc_execute, mount.nfs, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.779189] RPC: 6 xprt_complete_rqst, swapper, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (112 bytes received)
[ 22.779257] RPC: 6 __rpc_execute, mount.nfs, GETATTR, status = 0
[ 22.779282] RPC: 6 __rpc_execute, mount.nfs, GETATTR return 0, status 0
[ 22.779579] RPC: 7 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.779897] RPC: 7 xprt_complete_rqst, swapper, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (80 bytes received)
[ 22.779961] RPC: 7 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 22.779990] RPC: 7 __rpc_execute, mount.nfs, FSINFO return 0, status 0
[ 22.780085] RPC: 8 __rpc_execute, mount.nfs, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.780357] RPC: 8 xprt_complete_rqst, swapper, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (112 bytes received)
[ 22.780424] RPC: 8 __rpc_execute, mount.nfs, GETATTR, status = 0
[ 22.780450] RPC: 8 __rpc_execute, mount.nfs, GETATTR return 0, status 0
[ 22.780617] RPC: 9 __rpc_execute, mount.nfs, p_name: FSSTAT,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 22.780980] RPC: 9 xprt_complete_rqst, swapper, p_name: FSSTAT,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (88 bytes received)
[ 22.781062] RPC: 9 __rpc_execute, mount.nfs, FSSTAT, status = 0
[ 22.781089] RPC: 9 __rpc_execute, mount.nfs, FSSTAT return 0, status 0
[ 30.796291] RPC: 3 __rpc_execute, mount.nfs, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 30.796815] RPC: 3 xprt_complete_rqst, Compositor0, p_name: (null),
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (24 bytes received)
[ 30.819805] RPC: 3 __rpc_execute, mount.nfs, (null), status = 0
[ 30.825609] RPC: 3 __rpc_execute, mount.nfs, (null) return 0, status 0
[ 30.835104] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 33.840921] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 33.846205] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 33.856753] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 39.856950] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 39.862282] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003

[ 39.862305] nfs: server 10.123.175.123 not responding, still trying

[ 39.862413] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 42.864953] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 42.870466] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 42.880837] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 48.880934] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 48.886353] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 48.896662] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 51.896932] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 51.902119] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 51.912784] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 57.920947] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 57.926371] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 57.936706] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 60.936923] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 60.942159] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 60.952484] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 66.961002] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 66.966352] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 66.976894] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 69.977036] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 69.982432] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 69.992875] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 76.001029] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 76.006535] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 76.017198] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 79.024935] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 79.030126] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 79.041136] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 85.057091] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 85.062802] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 85.073529] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 88.080982] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 88.086258] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 88.097291] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 94.112971] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 94.118263] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 94.128722] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 97.130086] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 97.547222] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 97.560442] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 103.572923] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 103.572952] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 103.573102] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 106.580922] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 106.580963] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 106.581082] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 112.593015] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 112.598653] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 112.609505] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 115.617057] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 115.623197] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 115.633568] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 121.668805] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 121.668834] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 121.668963] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 124.656940] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 124.662122] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 124.672405] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 130.672935] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 130.678118] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 130.688401] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 133.688937] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 133.694121] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 133.704421] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 139.712942] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 139.718125] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 139.728410] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 142.729077] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 142.734309] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 142.744637] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 148.752956] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 148.758143] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 148.768465] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 151.768958] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 151.774147] RPC: 5 call_timeout, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 0 ms, prog: 100003
[ 151.784467] RPC: 5 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003
[ 151.790083] RPC: 5 xprt_complete_rqst, swapper, p_name: FSINFO,
tk_status: 0, tk_timeout: 6000 ms, prog: 100003, (80 bytes received)
[ 151.807023] RPC: 5 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 151.817655] RPC: 5 __rpc_execute, mount.nfs, FSINFO return 0, status 0
[ 151.824483] RPC: 6 __rpc_execute, mount.nfs, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 151.824994] RPC: 6 xprt_complete_rqst, swapper, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (112 bytes received)
[ 151.846876] RPC: 6 __rpc_execute, mount.nfs, GETATTR, status = 0
[ 151.852807] RPC: 6 __rpc_execute, mount.nfs, GETATTR return 0, status 0
[ 151.860776] RPC: 7 __rpc_execute, mount.nfs, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 151.861233] RPC: 7 xprt_complete_rqst, swapper, p_name: FSINFO,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (80 bytes received)
[ 151.882808] RPC: 7 __rpc_execute, mount.nfs, FSINFO, status = 0
[ 151.888553] RPC: 7 __rpc_execute, mount.nfs, FSINFO return 0, status 0
[ 151.896241] RPC: 8 __rpc_execute, mount.nfs, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 151.896638] RPC: 8 xprt_complete_rqst, swapper, p_name: GETATTR,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (112 bytes received)
[ 151.918595] RPC: 8 __rpc_execute, mount.nfs, GETATTR, status = 0
[ 151.924479] RPC: 8 __rpc_execute, mount.nfs, GETATTR return 0, status 0
[ 151.932272] RPC: 9 __rpc_execute, mount.nfs, p_name: FSSTAT,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003
[ 151.932648] RPC: 9 xprt_complete_rqst, swapper, p_name: FSSTAT,
tk_status: 0, tk_timeout: 3000 ms, prog: 100003, (88 bytes received)
[ 151.954573] RPC: 9 __rpc_execute, mount.nfs, FSSTAT, status = 0
[ 151.960320] RPC: 9 __rpc_execute, mount.nfs, FSSTAT return 0, status 0


Is there any idea what could be the possible causes? is it the network
or NFSD ? Or anything else?

Since, I have changed the values for NFS_DEF_TCP_TIMEO,
NFS_MAX_TCP_TIMEOUT - in the logs it shows to retry after '3sec' and
'6secs'.

Please suggest as this has become critical problem.Any debugging
things i can try?

Regards,
Amit Sahrawat
