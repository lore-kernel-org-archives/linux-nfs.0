Received: from mail-oo1-f45.google.com (mail-oo1-f45.google.com [209.85.161.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6DCC2391E73
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403186; cv=none; b=ReKTBYmp1FUBh3r5JQCHe5DPBFZB7iNOfWsoHEQLRt4HniqsowdF2GJiuBruFRFXRUX3L98GPfcEP5FLFqVvhrmFFXAig7CVXQFkSJPUokRQtPMQUh8eYDWhoBqIZ+7lEHt63xvPV3wMikxpxfOgTgCf56l2PRcdkSyQarS46cs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403186; c=relaxed/simple;
	bh=9a4Dm60vxtzlMbXWA8VDF1XlH2veWvjBLLJqbddC/c0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ILKZba2PhKSUDas/HlizhtyosRg6hebcdyhrt9CwWMlPqM2Cq+B80eOfze9IXaVQikTClsnaUgZTTyRF85pyjXo0z9dauVq1oAXWeylx6hPzXJQk5W1/9PmTSMpeTIB2I16JXDJTy2PLuwGgEx6bR/IocXYxyV+upmVXtObiYko=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=VQJCWDIi; arc=none smtp.client-ip=209.85.161.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="VQJCWDIi"
Received: by mail-oo1-f45.google.com with SMTP id 006d021491bc7-6d7e06dbcccso1564759eaf.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403184; x=1792007984; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ORNIi3goQ2NILjOPLuvwnDpMQPxIS+GPNDMPNL6cdzg=;
        b=VQJCWDIiCMpmykN5cfBT1dGOTvqgc5vRuYjepDPIGfbdlEcKfLm5oCb7qlcHW1zU2n
         DezVlt9uZwB4xmLLr9h2C0E5E1r9uEUYvQAsn3NCTVSOT9+d3InZCEwh+1E5xmg8xTzf
         cscX5MZwhUqG3Yv5yy8j7+BBFG9FLxjQD4yGuPx/WWJrOKN6fSNmlWsh3bQK+8MtOJ3l
         /yfQAYppYW3gh8VjJR1bLwH5irLq3gm+wOG7sPGEDOR5Osdzn9/a2z7FT7J3vi10vr8P
         VkULc+k9w08S7lKg/uk4PHvEdH0+fhK7lUa/m6A1mX8TLzT5jDLOKXg0fEd4W4PAuwt/
         pOqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403184; x=1792007984;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ORNIi3goQ2NILjOPLuvwnDpMQPxIS+GPNDMPNL6cdzg=;
        b=N9NY25R0Fs7AG18lSsLjGj/qtEPAgsn9JMjLJvWfud7zx1yWsS13RKSr9vEaAcpWN8
         DW7nbkVGLFq9G0PLFMBqoBziE6p1KOO+YMi7F40NLOL9MBz3dRhoQGenyaqbiSIKEbt/
         0xTLf6UDKqvaP+z+UQTJLMoBu7YzL74lMz1e+vdsrRRbuzdxieXDect5kbee+ZcKU1U/
         UgsPJvjmmBYB7bHYnhnWFOI6FXq7xquyTYiBzbEkG0PobafaquF8idTZBN41haLRAvcs
         tZfy4V68mVJgFwvJpi2PvS/0Afogf74X6w4EZYU9veviHHrjaJImiPm0B2faSLZF3NDK
         lHtw==
X-Gm-Message-State: AFuF++mRnvmMM9AqRS1YP48X9nJvYPbWAyCx+sA7tH0okzR4qGzgfT61
	NC4Eqw9c4KRTVSbPF6ITsLgOmeeeJGtle8d1NVTEbx6F/yv8BbeeP7HRFK2HLDKWeYOgqZie6Wg
	qZcsl
X-Gm-Gg: AYBFou1yLxQBQ018/dsUIuX0s1rlZPjJcHX+xk/ASJQkPF8eTvS6zLwvjxjeZvalojX
	Xutvnww9GGsey+QjKJKQKvJFkmVCBh/egZ9b5MnizKdFCT+G+8rwHU1W70RkAUtpMtLyhbFcKmU
	wIK7QfZm7E/hDcppynDrhut7iVEgSYeNiXsvC/4k/LgWHu3sNOj4bJ2TRMBTRZ9npdNh1KrwHxw
	iOycBB4yaxl8MttdkOoa2/SMkily2ZIlZEqUcw+5C1zRrPE7Z6X+qSEgkcS1InjZJK9r+fBFMGE
	Z2HHhbgrMVpjtR1TH+9/o3raP1OTAkSPHUNABLXNOQ8xESEf6cA+//xgVyh1v8qXxvloSRDQX53
	jSpyeTdU4F/HbGRtT39asoWmu/78GG2ZFMnoa3ECQ6ShlvgQZmRQSb9aDhizLxoO4Z1OhEXls5m
	dr1jyTNc8TL6IOCmgnesn0DzarXPl33j8Fi9b7DEZtyVFkBh/tw7DkxZYc2A2OwlbGNPKjZGySA
	RdqTDSXRh2cMOF5TMPT5zqRDHbUj/5nfdsYzrpxrA==
X-Received: by 2002:a05:6820:1a0c:b0:6c9:80d8:a1ea with SMTP id 006d021491bc7-6e7a8050b6cmr3013643eaf.39.1791403184292;
        Wed, 07 Oct 2026 12:59:44 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 4/9] SUNRPC: report the transport's class in the svc_xprt_dequeue tracepoint
Date: Wed,  7 Oct 2026 15:59:29 -0400
Message-ID: <27416e906f563f9b5c9c9231d4a0406193d04890.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

With dispatch round-robin across clients, which client a transport
was served as matters as much as its address.  Print the class the
transport was bound to at accept: 0 for the anonymous client, the
class number otherwise, with "+addr" when the client is one address
within the class.  The peer address is already in the event.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/trace/events/sunrpc.h | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 77efe63d2c14..107fbed5d556 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -2042,20 +2042,27 @@ TRACE_EVENT(svc_xprt_dequeue,
 
 	TP_STRUCT__entry(
 		SVC_XPRT_ENDPOINT_FIELDS(rqst->rq_xprt)
+		__field(u32, class)
+		__field(bool, per_addr)
 		__field(unsigned long, wakeup)
 		__field(unsigned long, qtime)
 	),
 
 	TP_fast_assign(
 		ktime_t ktime = ktime_get();
+		u32 class = rqst->rq_xprt->xpt_client->cl_class;
 
 		SVC_XPRT_ENDPOINT_ASSIGNMENTS(rqst->rq_xprt);
+		__entry->class = class & ~SVC_CLASS_PER_ADDR;
+		__entry->per_addr = class & SVC_CLASS_PER_ADDR;
 		__entry->wakeup = ktime_to_us(ktime_sub(ktime, rqst->rq_qtime));
 		__entry->qtime = ktime_to_us(ktime_sub(ktime, rqst->rq_xprt->xpt_qtime));
 	),
 
-	TP_printk(SVC_XPRT_ENDPOINT_FORMAT " wakeup-us=%lu qtime-us=%lu",
-		SVC_XPRT_ENDPOINT_VARARGS, __entry->wakeup, __entry->qtime)
+	TP_printk(SVC_XPRT_ENDPOINT_FORMAT " class=%u%s wakeup-us=%lu qtime-us=%lu",
+		  SVC_XPRT_ENDPOINT_VARARGS,
+		  __entry->class, __entry->per_addr ? "+addr" : "",
+		  __entry->wakeup, __entry->qtime)
 );
 
 DECLARE_EVENT_CLASS(svc_xprt_event,
-- 
2.53.0

