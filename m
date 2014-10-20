Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbaJTFMc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2014 01:12:32 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s9K5CWk7009370
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2014 01:12:32 -0400
Received: from mmyllyne.csb (vpn1-5-245.ams2.redhat.com [10.36.5.245])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s9K5CVJV002459
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2014 01:12:31 -0400
Message-ID: <544499BA.1050408@redhat.com>
Date: Mon, 20 Oct 2014 08:12:26 +0300
From: Marko Myllynen <myllynen@redhat.com>
Reply-To: myllynen@redhat.com
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsstat: fix server rpc stats header
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux/net/sunrpc/stats.c has:

/*
 * Get RPC server stats
 */
void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
...
        seq_printf(seq,
                "rpc %u %u %u %u %u\n",
                        statp->rpccnt,
                        statp->rpcbadfmt+statp->rpcbadauth+statp->rpcbadclnt,
                        statp->rpcbadfmt,
                        statp->rpcbadauth,
                        statp->rpcbadclnt);
...

But when /proc/net/rpc/nfsd contains

rpc 1 2 3 4 5

nfsstat -sv prints:

Server rpc stats:
calls      badcalls   badclnt    badauth    xdrcall
1          2          3          4          5

Change this to match the kernel:

Server rpc stats:
calls      badcalls   badfmt     badauth    badclnt
1          2          3          4          5

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=1142842.

Signed-off-by: Marko Myllynen <myllynen@redhat.com>
---
 utils/nfsstat/nfsstat.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 18e4d27..9f481db 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -558,7 +558,7 @@ print_server_stats(int opt_prt)
 			;
 		} else {
 			print_numbers(LABEL_srvrpc
-				"calls      badcalls   badclnt    badauth    xdrcall\n",
+				"calls      badcalls   badfmt     badauth    badclnt\n",
 				srvrpcinfo, 5);
 			printf("\n");
 		}
-- 
1.7.1

-- 
Marko Myllynen
