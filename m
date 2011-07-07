Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104Ab1GGILu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 04:11:50 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p678BnOx018952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 7 Jul 2011 04:11:50 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p678Bnuc024175
	for <linux-nfs@vger.kernel.org>; Thu, 7 Jul 2011 04:11:49 -0400
Received: from regina.usersys.redhat.com (dhcp-176-225.mel.redhat.com [10.64.176.225])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id p678BmKO015118
	for <linux-nfs@vger.kernel.org>; Thu, 7 Jul 2011 04:11:48 -0400
Content-Type: text/plain; charset=utf-8
Message-ID: <19989.27202.793003.725608@regina.usersys.redhat.com>
Date: Thu, 7 Jul 2011 18:11:46 +1000
From: Max Matveev <makc@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: NFS/TCP timeout sequence
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


I've had to look at the way NFS/TCP does its timeouts and backoff
and it does not make a lot of sense to me: according to the
following paragram from nfs(5) on Fedora 14 (I'm using Fedora 14
because it has more text then the same page in nfs-utils):

      timeo=n    The time (in tenths of a second) the  NFS  client  waits
                 for a response before it retries an NFS request. If this
                 option is not specified, requests are retried  every  60
                 seconds  for NFS over TCP.  The NFS client does not per‐
                 form any kind of timeout backoff for NFS over TCP.

but if I try the mount with timeo=20,retrans=7 then I'm getting
retransmits which are 2, 4, 6, 8, 2, 4, 6, 8 seconds apart, i.e.
there is a) linear backoff and b) the backoff is not long enough to
let the complete sequence of 7 retransmits run its course.

This is happening because to_maxval for NFS_TCP is too short to
accomodate the linear backoff - we need to either increase the
to_maxval to something like:

--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -606,7 +606,8 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, 
                if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
                        to->to_initval = NFS_MAX_TCP_TIMEOUT;
                to->to_increment = to->to_initval;
-               to->to_maxval = to->to_initval + (to->to_increment * to->to_retries);
+               to->to_maxval = to->to_increment * (to->to_retries + 1) 
+                             * (to->to_retries + 2) / 2;
                if (to->to_maxval > NFS_MAX_TCP_TIMEOUT)
                        to->to_maxval = NFS_MAX_TCP_TIMEOUT;
                if (to->to_maxval < to->to_initval)

or don't do the linear backoff

--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -546,7 +546,7 @@ static void xprt_reset_majortimeo(struct rpc_rqst *req)
        if (to->to_exponential)
                req->rq_majortimeo <<= to->to_retries;
        else
-               req->rq_majortimeo += to->to_increment * to->to_retries;
+               req->rq_majortimeo += to->to_increment;
        if (req->rq_majortimeo > to->to_maxval || req->rq_majortimeo == 0)
                req->rq_majortimeo = to->to_maxval;
        req->rq_majortimeo += jiffies;

max
