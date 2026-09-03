Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2597E4A3D35
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:43:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457388; cv=none; b=rUcT0hHVwSbT2Vc41jt3ETvIkcHqIo/jURO8XW/PvV5ubV/ZaUmMvpXDUjmPb31vncezZcLAlEjw6eWK5hhJ0eqrvRqVQ77yg2v5+9Kz5alclwJaBNOva1Pppf+muZUsUcrGOwy4EVSI/mRoyDJpKw5HuBuP/6t0IeL2gFn7Vdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457388; c=relaxed/simple;
	bh=/zoRE0RIaaM91fHtU/VQReyvu+aF6EbisTfc7cxwyBo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hkU7yokySz8MyGM9z1UWBb+10aSxknKxnW0xcgTsbZnXCcvwNUla+/Q4iPk4xhlG5NgTHOMzRXLEDzV4DLXxxAnuxCYcxVIcRB/Fi8T84EmTsqYG6XHG02n2Z153h1muoOSmgEtFbXTB3XMr212nqKUVDrk6lIoUrP+IgHUjhtQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=CocN8H/t; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CocN8H/t"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457384;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=8Gjpd56iOrWpddE/Kt5kVr0TzZ0FyVJx+vpgl6XoBG8=;
	b=CocN8H/tjwINKEOO6VZwen6rxny/g7ItwZr6LpEkOT8tJhMbEQsg/4DBT5jhRVWTblkHW1
	WJ7/qdqSNGkAaPL1GYWjaB5sM0kiZPAZq8sR0Zz50f7eBrpOuFi+zXcQb/+CPEYjPONUhh
	gY1WiyN6JStZ1msHE7624l1KSVFa8iM=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-568-TpKXdBBLMcqUG4YzxIhByQ-1; Thu,
 03 Sep 2026 13:42:52 -0400
X-MC-Unique: TpKXdBBLMcqUG4YzxIhByQ-1
X-Mimecast-MFC-AGG-ID: TpKXdBBLMcqUG4YzxIhByQ_1788457366
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A82051955BF4
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 817057E2;
	Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id E9F4053458C9;
	Thu, 03 Sep 2026 13:42:45 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 3/6] rpcbind: fully disable remote calls when --enable-rmtcalls is unset
Date: Thu,  3 Sep 2026 13:42:42 -0400
Message-ID: <20260903174245.1213147-4-smayhew@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
References: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Commit 2e9c289 ("rpcbind: Disable remote calls by default") added the
'--enable-rmtcalls' option, which is off by default, but that only
suppresses the creation of the rmtcallfd for a given netconfig entry.

In this case a client can still send rpcbind CALLIT/BCAST/INDIRECT
requests, which will eventually bail out in rpcbproc_callit_com() after
find_rmtcallfd_by_netid() fails... but by that point rpcbind may have
called logit() (which forks a child process) or rpcbs_rmtcall() (which
allocates a stats bucket if the request contained a unique program or
procedure number).

If configure is run without the '--enable-rmtcalls' option, then fully
disable remote call functionality.  Attempts to call
CALLIT/BCAST/INDIRECT will receive an accept state of PROC_UNAVAIL.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/pmap_svc.c     |  2 ++
 src/rpcb_stat.c    |  2 ++
 src/rpcb_svc.c     |  2 ++
 src/rpcb_svc_4.c   |  2 ++
 src/rpcb_svc_com.c | 19 ++++++++++++++++---
 src/rpcbind.h      |  5 +++++
 src/security.c     |  4 ++++
 7 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/src/pmap_svc.c b/src/pmap_svc.c
index e5a5d0f..27091ac 100644
--- a/src/pmap_svc.c
+++ b/src/pmap_svc.c
@@ -125,6 +125,7 @@ pmap_service(struct svc_req *rqstp, SVCXPRT *xprt)
 		pmapproc_dump(rqstp, xprt);
 		break;
 
+#ifdef RMTCALLS
 	case PMAPPROC_CALLIT:
 		/*
 		 * Calls a procedure on the local machine. If the requested
@@ -135,6 +136,7 @@ pmap_service(struct svc_req *rqstp, SVCXPRT *xprt)
 		 */
 		rpcbproc_callit_com(rqstp, xprt, PMAPPROC_CALLIT, PMAPVERS);
 		break;
+#endif /* RMTCALLS */
 
 	default:
 		svcerr_noproc(xprt);
diff --git a/src/rpcb_stat.c b/src/rpcb_stat.c
index 0799a47..ef2b3a9 100644
--- a/src/rpcb_stat.c
+++ b/src/rpcb_stat.c
@@ -160,6 +160,7 @@ rpcbs_getaddr(rpcvers_t rtype, rpcprog_t prog, rpcvers_t vers, char *netid,
 	}
 }
 
+#ifdef RMTCALLS
 void
 rpcbs_rmtcall(rpcvers_t rtype, rpcproc_t rpcbproc, rpcprog_t prog,
 	      rpcvers_t vers, rpcproc_t proc, char *netid, rpcblist_ptr rbl)
@@ -225,6 +226,7 @@ rpcbs_rmtcall(rpcvers_t rtype, rpcproc_t rpcbproc, rpcprog_t prog,
 		}
 	}
 }
+#endif /* RMTCALLS */
 
 void *
 rpcbproc_getstat(void *arg /*__unused*/, struct svc_req *req /*__unused*/,
diff --git a/src/rpcb_svc.c b/src/rpcb_svc.c
index 091f530..e52e82f 100644
--- a/src/rpcb_svc.c
+++ b/src/rpcb_svc.c
@@ -122,9 +122,11 @@ rpcb_service_3(struct svc_req *rqstp, SVCXPRT *transp)
 		local = rpcbproc_dump_3_local;
 		break;
 
+#ifdef RMTCALLS
 	case RPCBPROC_CALLIT:
 		rpcbproc_callit_com(rqstp, transp, rqstp->rq_proc, RPCBVERS);
 		return;
+#endif /* RMTCALLS */
 
 	case RPCBPROC_GETTIME:
 #ifdef RPCBIND_DEBUG
diff --git a/src/rpcb_svc_4.c b/src/rpcb_svc_4.c
index eebbbbe..dbb8839 100644
--- a/src/rpcb_svc_4.c
+++ b/src/rpcb_svc_4.c
@@ -141,6 +141,7 @@ rpcb_service_4(struct svc_req *rqstp, SVCXPRT *transp)
 		local = rpcbproc_dump_4_local;
 		break;
 
+#ifdef RMTCALLS
 	case RPCBPROC_INDIRECT:
 #ifdef RPCBIND_DEBUG
 		if (debugging)
@@ -157,6 +158,7 @@ rpcb_service_4(struct svc_req *rqstp, SVCXPRT *transp)
 #endif
 		rpcbproc_callit_com(rqstp, transp, rqstp->rq_proc, RPCBVERS4);
 		return;
+#endif /* RMTCALLS */
 
 	case RPCBPROC_GETTIME:
 #ifdef RPCBIND_DEBUG
diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
index 6d0d72d..0763fc4 100644
--- a/src/rpcb_svc_com.c
+++ b/src/rpcb_svc_com.c
@@ -74,6 +74,8 @@
 
 
 static char *nullstring = "";
+
+#ifdef RMTCALLS
 static int rpcb_rmtcalls;
 
 struct rmtcallfd_list {
@@ -120,6 +122,8 @@ static void xprt_set_caller(SVCXPRT *, struct finfo *);
 static void send_svcsyserr(SVCXPRT *, struct finfo *);
 static void handle_reply(int, SVCXPRT *);
 static void find_versions(rpcprog_t, char *, rpcvers_t *, rpcvers_t *);
+#endif /* RMTCALLS */
+
 static rpcblist_ptr find_service(rpcprog_t, rpcvers_t, char *);
 static char *getowner(SVCXPRT *, char *, size_t);
 static int add_pmaplist(RPCB *);
@@ -429,7 +433,7 @@ rpcbproc_taddr2uaddr_com(void *arg, struct svc_req *rqstp /*__unused*/,
 	return (void *)&uaddr;
 }
 
-
+#ifdef RMTCALLS
 static bool_t
 xdr_encap_parms(XDR *xdrs, struct encap_parms *epp)
 {
@@ -1048,12 +1052,15 @@ netbuffree(struct netbuf *ap)
 	free(ap->buf);
 	free(ap);
 }
-
+#endif /* RMTCALLS */
 
 void
 my_svc_run()
 {
-	int poll_ret, check_ret;
+	int poll_ret;
+#ifdef RMTCALLS
+	int check_ret;
+#endif /* RMTCALLS */
 
 	for (;;) {
 	        struct pollfd my_pollfd[svc_max_pollfd];
@@ -1087,14 +1094,19 @@ my_svc_run()
 			 * don't call svc_getreq_poll.  Otherwise, there
 			 * must be another so we must call svc_getreq_poll.
 			 */
+#ifdef RMTCALLS
 			if ((check_ret = check_rmtcalls(my_pollfd, svc_max_pollfd)) ==
 			    poll_ret)
 				continue;
 			svc_getreq_poll(my_pollfd, poll_ret-check_ret);
+#else
+			svc_getreq_poll(my_pollfd, poll_ret);
+#endif /* RMTCALLS */
 		}
 	}
 }
 
+#ifdef RMTCALLS
 static int
 check_rmtcalls(struct pollfd *pfds, int nfds)
 {
@@ -1289,6 +1301,7 @@ find_versions(rpcprog_t prog, char *netid, rpcvers_t *lowvp, rpcvers_t *highvp)
 	*highvp = highv;
 	return;
 }
+#endif /* RMTCALLS */
 
 /*
  * returns the item with the given program, version number and netid.
diff --git a/src/rpcbind.h b/src/rpcbind.h
index 5b1a9bb..ef3aab8 100644
--- a/src/rpcbind.h
+++ b/src/rpcbind.h
@@ -89,8 +89,10 @@ void rpcbs_procinfo(rpcvers_t, rpcproc_t);
 void rpcbs_set(rpcvers_t, bool_t);
 void rpcbs_unset(rpcvers_t, bool_t);
 void rpcbs_getaddr(rpcvers_t, rpcprog_t, rpcvers_t, char *, char *);
+#ifdef RMTCALLS
 void rpcbs_rmtcall(rpcvers_t, rpcproc_t, rpcprog_t, rpcvers_t, rpcproc_t,
 			char *, rpcblist_ptr);
+#endif /* RMTCALLS */
 void *rpcbproc_getstat(void *, struct svc_req *, SVCXPRT *, rpcvers_t);
 
 void rpcb_service_3(struct svc_req *, SVCXPRT *);
@@ -110,9 +112,12 @@ void *rpcbproc_uaddr2taddr_com(void *, struct svc_req *,
 					     SVCXPRT *, rpcvers_t);
 void *rpcbproc_taddr2uaddr_com(void *, struct svc_req *, SVCXPRT *,
 				    rpcvers_t);
+#ifdef RMTCALLS
 int create_rmtcall_fd(struct netconfig *);
 void rpcbproc_callit_com(struct svc_req *, SVCXPRT *, rpcvers_t,
 			      rpcvers_t);
+#endif /* RMTCALLS */
+
 void my_svc_run(void);
 
 void rpcbind_abort(void);
diff --git a/src/security.c b/src/security.c
index 02651d7..6bd22fd 100644
--- a/src/security.c
+++ b/src/security.c
@@ -99,8 +99,10 @@ check_access(SVCXPRT *xprt, rpcproc_t proc, rpcprog_t prog, unsigned int rpcbver
 		}
 		break;
 	case RPCBPROC_GETADDR:
+#ifdef RMTCALLS
 	case RPCBPROC_CALLIT:
 	case RPCBPROC_INDIRECT:
+#endif /* RMTCALLS */
 	case RPCBPROC_DUMP:
 	case RPCBPROC_GETTIME:
 	case RPCBPROC_UADDR2TADDR:
@@ -290,6 +292,7 @@ logit(int severity, struct sockaddr *addr, rpcproc_t procnum, rpcprog_t prognum,
 	}
 }
 
+#ifdef RMTCALLS
 int
 check_callit(SVCXPRT *xprt, struct r_rmtcall_args *args, int versnum /*__unused*/)
 {
@@ -353,3 +356,4 @@ deny:
 #endif
 	return 0;
 }
+#endif /* RMTCALLS */
-- 
2.55.0

