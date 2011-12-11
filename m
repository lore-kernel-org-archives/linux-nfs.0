Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60871 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751836Ab1LKMkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 07:40:11 -0500
Date: Sun, 11 Dec 2011 13:40:08 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
Message-ID: <20111211124008.GA10460@janus>
References: <20111205165021.GA24165@janus>
 <1323128376.7237.7.camel@lade.trondhjem.org>
 <20111206081115.GA3570@janus>
 <1323201463.3199.18.camel@lade.trondhjem.org>
 <20111207134359.GA29828@janus>
 <1323486601.32695.2.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323486601.32695.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 09, 2011 at 10:10:01PM -0500, Trond Myklebust wrote:
> [...]
> I'm still mystified as to what is going on here...
> 
> Would it be possible to upgrade some of your clients to 3.1.5 (which
> contains a fix for a sunrpc socket buffer problem) and then to add the
> following patch?

Did so, the mount locked up and still is, ready for some more
experimentation. I don't see any difference however. Did a
echo 0 >/proc/sys/sunrpc/rpc_debug afterwards (see below).

A recipe which seems to trigger the issue (at least occasionally) is

	cd /mount-point
	ssh server echo 3 \>/proc/sys/vm/drop_caches
	echo 3 >/proc/sys/vm/drop_caches
	for i in `seq 100`
	do
		du >/dev/null 2>&1 &
	done

I'll try it on a pristine kernel to rule out some kernel patches (unlikely to
be the cause or trigger but just to be sure).

-pid- flgs status -client- --rqstp- -timeout ---ops--
29785 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:none
29902 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29903 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29907 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29920 0080    -11 f519b6b0 f2606980        0 c191c4ac nfsv3 GETATTR a:call_status q:xprt_sending
29921 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29922 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29923 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29924 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29925 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29926 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29927 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29928 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29929 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29930 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29931 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29932 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29933 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29934 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29935 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29936 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29937 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29938 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29939 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29940 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29941 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29942 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29943 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29944 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29945 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29946 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29947 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29948 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29949 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29950 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29951 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29952 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29953 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29954 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29955 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29956 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29957 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29958 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29959 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29960 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29961 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29962 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29963 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29964 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29965 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29966 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29967 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29968 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29969 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29970 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29971 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29972 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29973 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29974 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29975 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29976 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29977 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29978 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29979 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29980 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29981 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29982 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29983 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29984 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29985 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29986 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29987 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29988 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29989 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29990 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29991 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29992 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29993 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29994 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29995 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29996 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29997 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29998 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
29999 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30000 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30001 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30002 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30003 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30004 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30005 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30006 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30007 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30008 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30009 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30010 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30011 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30012 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30013 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30014 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30015 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
30025 0080    -11 f519b6b0   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending

-- 
Frank
