Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759242Ab3ECR0A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 13:26:00 -0400
Date: Fri, 3 May 2013 13:25:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
Message-ID: <20130503132557.2fdf794d@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've noticed that when running a 3.10-pre kernel that if I try to mount
up a NFSv4 filesystem that it now takes ~15s for the mount to complete.

Here's a little rpcdebug output:

[ 3056.385078] svc: server ffff8800368fc000 waiting for data (to = 9223372036854775807)
[ 3056.392056] RPC:       new task initialized, procpid 2471
[ 3056.392758] RPC:       allocated task ffff88010cd90100
[ 3056.393303] RPC:    42 __rpc_execute flags=0x1280
[ 3056.393630] RPC:    42 call_start nfs4 proc SETCLIENTID (sync)
[ 3056.394056] RPC:    42 call_reserve (status 0)
[ 3056.394368] RPC:    42 reserved req ffff8801019f9600 xid 21ad6c40
[ 3056.394783] RPC:       wake_up_first(ffff88010a989990 "xprt_sending")
[ 3056.395252] RPC:    42 call_reserveresult (status 0)
[ 3056.395595] RPC:    42 call_refresh (status 0)
[ 3056.395901] RPC:       gss_create_cred for uid 0, flavor 390004
[ 3056.396361] RPC:       gss_create_upcall for uid 0
[ 3071.396134] RPC: AUTH_GSS upcall timed out.
Please check user daemon is running.
[ 3071.397374] RPC:       gss_create_upcall for uid 0 result -13
[ 3071.398192] RPC:    42 call_refreshresult (status -13)
[ 3071.398873] RPC:    42 call_refreshresult: refresh creds failed with error -13
[ 3071.399881] RPC:    42 return 0, status -13

The problem is that we're now trying to upcall for GSS creds to do the
SETCLIENTID call, but this host isn't running rpc.gssd. Not running
rpc.gssd is pretty common for people not using kerberized NFS. I think
we'll see a lot of complaints about this.

Is this expected? If so, what's the proposed remedy? Simply have
everyone run rpc.gssd even if they're not using kerberized NFS?


-- 
Jeff Layton <jlayton@redhat.com>
