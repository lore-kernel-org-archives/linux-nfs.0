Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60DFC42E8C2
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653819; cv=none; b=dGHTa6jQ/n6CkdGsBD/xKtztC0Bu3hlL822voIcdADoF14jaS+KV1KZsfxah1C1QUtwYZ7kcAVeHq/LnGQ8zPJ47TaAxKjFpkUVFXiklW/8WABK7360FV0WlG5Fq+spWs2tQl3+m+0Mvmt6B3XZFAOwsipOWlm6N0nw+2U5/KRg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653819; c=relaxed/simple;
	bh=o0jw/JICwGmC9Yp0m1yxfDt0n7j/iQMptwgnzqSBU2M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Qn8wjVkusNtyfSyKeu9MsydM9vPz47holMAcOkAwS/GdGV2eI7ISgQFFu7t4ZJPVRkatha8R3gh4eoEXFxtrPsxyVr5PSRI/Cq986SDfqV9Z++tKKfQMY5iD8MRN8LHCDPN6ayQbC8kpMJwArKDNdNuSswgpj/VSeAS1ba67FK8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=XmKId256; arc=none smtp.client-ip=209.85.167.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XmKId256"
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-49fa951b2c6so145793b6e.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653817; x=1787258617; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HsCei+VxH16AbxNGkNQLjYKYXX/IhUI7dnlg//dbBdI=;
        b=XmKId256i2MLkSfFPm7lmxUJEqmeJxdfsHj4cTD3gbdOuasSm2uoKdef4HltMqxw8+
         eFo3sv5MQQdLZe5H5h9OeAFMSUeM84wbg1P8iI23bveGIF5aOAvcm+IlBO8LYmiuHost
         B+w5jhmMX1bFCXZ0+0E5gqOAvnqJ3u2u8cTk8ArPfIdcby4Tu4+FPaNpFeAc/ixt98+L
         wu3CF9mX6W4pCZPySHwBlNtcuVGUriu8qOS43l68ftMw/lMZD1iMqGoE6tSPG6wi2U3h
         pEFyXKRNaSmaVsX6wqYy33DQ1FCcdR+wAfR8rocV+WHcH4+ztXhrdGYeIILL/yxTQpQJ
         0AUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653817; x=1787258617;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HsCei+VxH16AbxNGkNQLjYKYXX/IhUI7dnlg//dbBdI=;
        b=M+2PqC3iWNfo4luby8XbNO/UGdByZtz2Mbn7vPsunXho2U8ucIt6aoejWozw7WnpHO
         bXdvuIh/b2kVgzjIVw18B2HLI0CDfdL0jgZdjOFbDNcSJDHBye9U3+8QopKyatGxmi7a
         Vo1z5Ql/2IrIJvSDKsRr/2++GNp9vWEjwYr1ouUsqVvsxo14MvCPKkNSo8Gt/u5zy/jN
         6DXTD/Kxz7TK463HMgBNSP2z/ObSPc13MHqurieCU0G5WRvOQK5tVrcANpcnys3ROlyt
         Y4GAjKm2L4u8fSz91hzXx4MiVz8l3aEy1o1+z4I6aZnfHm2eCT1cJDSSSiLTY7CCDBB2
         WJfA==
X-Gm-Message-State: AOJu0YzOFzCpN1MlEhqloNzan2XAZhNtIpDGfiOwhjNEfOKrhzZ/LTaB
	fn+uxyangBJPSsSavKmVxwO4jW1gvWW7MjxQ6zoGatbN6NJwPkmO3HtpwsgHkr+ebANMPXXl6M3
	Lx3iX
X-Gm-Gg: AR+sD11+RxHW30thD+PbWdbLxQ3EOiSyOEHeZR1ci21/Vi8ptpVNmvm4vRxzuViaysC
	KacXW5bTmoJYExyf6Ft9Ij7t17NTEL+mb9Z8KC9ecxB/HTN6uwat9fLmMXB7l4WdA9vw3OGXmM1
	YVs6IrNnsCojItoDmQehWzKrg1RziIPT6u7FardIWbF8/RZzBhg8TB7FARwOdGkTplEdGW4M1vW
	Tv6GZMKwQ5iETRjywPBg2Yz1/G74WIrfFNs4PH7wJn0FL5dmh9XkOJfGHMUoQq47Q8Jc1/0jwJa
	W2YAfv+nefNFz3zlI0FGQtEIydI8TiaW4cZ4ZFG5x3Q0wa2uMbv7YZ1gAE5U3GGsGh3WJQyzNsS
	i+H4UwUWTeGt08VrS8gU7ShEizI/0V8N6I+pStl0Q7zRIUL+AcXGz6gf4g8rJCBt66U7EdTNohO
	TZA70EeeYh31xXVwV0vg5vooBjKUJosGhdMZ8foFN4ABMoZRsGWRp9L4ILxrkeg8jtbkvie+YVN
	blBtuThvCc53iRhNxynh9qrkoY1firqsQw=
X-Received: by 2002:a05:6808:14c3:b0:495:e997:528d with SMTP id 5614622812f47-4b2412a3ee6mr714073b6e.3.1786653817166;
        Thu, 13 Aug 2026 13:43:37 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 12/21] NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
Date: Thu, 13 Aug 2026 16:43:08 -0400
Message-ID: <16a5260e13676499924667e3c203c0e89d366169.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a CHANGE notification carries ndc_immediate, RFC 8881 Section
20.12 says the change is enforced immediately and the client might not
be able to complete pending I/O.  In addition to un-pinning the stripe's
device node, mark the old node unavailable so paths still holding a
reference stop selecting it; I/O the server rejects is re-driven onto
the freshly resolved mapping by the existing DS error handling.

The walk can also exchange out a node that already carries the new
mapping: a re-resolve that completed between the unhash and the walk
reaching the stripe, raced by this walk or by the walk of a later
CHANGE for the same deviceid.  Ripping such a node out is harmless (it
is still hashed, so the next I/O re-pins it from the cache), but it
must not be marked unavailable.  Stale vintages are distinguishable by
hashed-ness: every superseded node was unhashed before its walk began
and is never re-inserted, while a fresh node is inserted before it is
installed.  Only mark nodes that are no longer hashed.

Without ndc_immediate, pending I/O drains on the old mapping and only
new I/O re-resolves, as before.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index bb27bbea6c95..f042551dd23a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2535,6 +2535,23 @@ static void ff_layout_reresolve_deviceid(struct pnfs_layout_hdr *lo,
 				xchg(&mirror->dss[dss_id].mirror_ds, NULL));
 			if (IS_ERR_OR_NULL(old))
 				continue;
+			/*
+			 * ndc_immediate: the server is enforcing the change
+			 * now and pending I/O may not complete.  Mark the
+			 * old node unavailable so anyone still holding a
+			 * reference stops selecting it; I/O the server
+			 * rejects is re-driven onto the new mapping by the
+			 * existing DS error handling.
+			 *
+			 * Only stale vintages are unhashed: a node still
+			 * hashed was fetched after the stale cache entry
+			 * was removed and already carries the new mapping
+			 * (it can be exchanged out here by a walk that
+			 * lost a race with the re-resolve, or with the
+			 * walk of a later CHANGE); don't mark it.
+			 */
+			if (immediate && hlist_unhashed(&old->id_node.node))
+				nfs4_mark_deviceid_unavailable(&old->id_node);
 			list_add(&old->id_node.put_list, head);
 		}
 	}
-- 
2.53.0

