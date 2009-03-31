From: Greg Banks <gnb@sgi.com>
Subject: [patch 21/29] knfsd: remove unreported filehandle stats counters
Date: Wed, 01 Apr 2009 07:28:21 +1100
Message-ID: <20090331202945.732284000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22575 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762115AbZCaVCn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The file nfsfh.c contains two static variables nfsd_nr_verified and
nfsd_nr_put.  These are counters which are incremented as a side
effect of the fh_verify() fh_compose() and fh_put() operations,
i.e. at least twice per NFS call for any non-trivial workload.
Needless to say this makes the cacheline that contains them (and any
other innocent victims) a very hot contention point indeed under high
call-rate workloads on multiprocessor NFS server.  It also turns out
that these counters are not used anywhere.  They're not reported to
userspace, they're not used in logic, they're not even exported from
the object file (let alone the module).  All they do is waste CPU time.

So this patch removes them.

Tests on a 16 CPU Altix A4700 with 2 10gige Myricom cards, configured
separately (no bonding).  Workload is 640 client threads doing directory
traverals with random small reads, from server RAM.

Before
======

Kernel profile:

  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  6.05   2716.00  2716.00    30406     0.09     1.02  svc_process
  4.44   4706.00  1990.00     1975     1.01     1.01  spin_unlock_irqrestore
  3.72   6376.00  1670.00     1666     1.00     1.00  svc_export_put
  3.41   7907.00  1531.00     1786     0.86     1.02  nfsd_ofcache_lookup
  3.25   9363.00  1456.00    10965     0.13     1.01  nfsd_dispatch
  3.10  10752.00  1389.00     1376     1.01     1.01  nfsd_cache_lookup
  2.57  11907.00  1155.00     4517     0.26     1.03  svc_tcp_recvfrom
  ...
  2.21  15352.00  1003.00     1081     0.93     1.00  nfsd_choose_ofc  <----
  ^^^^ 

Here the function nfsd_choose_ofc() reads a global variable
which by accident happened to be located in the same cacheline as
nfsd_nr_verified.

Call rate:

nullarbor:~ # pmdumptext nfs3.server.calls
...
Thu Dec 13 00:15:27     184780.663
Thu Dec 13 00:15:28     184885.881
Thu Dec 13 00:15:29     184449.215
Thu Dec 13 00:15:30     184971.058
Thu Dec 13 00:15:31     185036.052
Thu Dec 13 00:15:32     185250.475
Thu Dec 13 00:15:33     184481.319
Thu Dec 13 00:15:34     185225.737
Thu Dec 13 00:15:35     185408.018
Thu Dec 13 00:15:36     185335.764

 
After
=====

kernel profile:

  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  6.33   2813.00  2813.00    29979     0.09     1.01  svc_process
  4.66   4883.00  2070.00     2065     1.00     1.00  spin_unlock_irqrestore
  4.06   6687.00  1804.00     2182     0.83     1.00  nfsd_ofcache_lookup
  3.20   8110.00  1423.00    10932     0.13     1.00  nfsd_dispatch
  3.03   9456.00  1346.00     1343     1.00     1.00  nfsd_cache_lookup
  2.62  10622.00  1166.00     4645     0.25     1.01  svc_tcp_recvfrom
[...]
  0.10  42586.00    44.00       74     0.59     1.00  nfsd_choose_ofc  <--- HA!!
  ^^^^

Call rate:

nullarbor:~ # pmdumptext nfs3.server.calls
...
Thu Dec 13 01:45:28     194677.118
Thu Dec 13 01:45:29     193932.692
Thu Dec 13 01:45:30     194294.364
Thu Dec 13 01:45:31     194971.276
Thu Dec 13 01:45:32     194111.207
Thu Dec 13 01:45:33     194999.635
Thu Dec 13 01:45:34     195312.594
Thu Dec 13 01:45:35     195707.293
Thu Dec 13 01:45:36     194610.353
Thu Dec 13 01:45:37     195913.662
Thu Dec 13 01:45:38     194808.675

i.e. about a 5.3% improvement in call rate.

Signed-off-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: David Chinner <dgc@sgi.com>
---

 fs/nfsd/nfsfh.c |    6 ------
 1 file changed, 6 deletions(-)

Index: bfields/fs/nfsd/nfsfh.c
===================================================================
--- bfields.orig/fs/nfsd/nfsfh.c
+++ bfields/fs/nfsd/nfsfh.c
@@ -27,9 +27,6 @@
 #define NFSDDBG_FACILITY		NFSDDBG_FH
 
 
-static int nfsd_nr_verified;
-static int nfsd_nr_put;
-
 /*
  * our acceptability function.
  * if NOSUBTREECHECK, accept anything
@@ -251,7 +248,6 @@ static __be32 nfsd_set_fh_dentry(struct 
 
 	fhp->fh_dentry = dentry;
 	fhp->fh_export = exp;
-	nfsd_nr_verified++;
 	return 0;
 out:
 	exp_put(exp);
@@ -552,7 +548,6 @@ fh_compose(struct svc_fh *fhp, struct sv
 			return nfserr_opnotsupp;
 	}
 
-	nfsd_nr_verified++;
 	return 0;
 }
 
@@ -609,7 +604,6 @@ fh_put(struct svc_fh *fhp)
 		fhp->fh_pre_saved = 0;
 		fhp->fh_post_saved = 0;
 #endif
-		nfsd_nr_put++;
 	}
 	if (exp) {
 		cache_put(&exp->h, &svc_export_cache);

--
Greg
