Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.173
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793900006;
	b=D87LGz7FLIpihqBj5JaO62oqKQbU1C7p3HgvwtRVq7pnafI8uoBEesLL/LoE/wM33kwi
	 EuKhQoiexr60ErP8Lpdlh1WFXQUGH8Da6k+VqJbOolBmpvLIMtqma0d/OqcnDzwTD2GB4
	 Hqzmd8FQ8ud1oGmDKG9+2FYtaI626VF3wfUM86LATKU6NE97V8tzKVGmR65eidUz1FHtw
	 hLBD2/V3uhZp26LsvC33kvkDAWtjBpu2e+MF7nmV7niGtyXr2sjj83zRueyFyL49WbTJh
	 pDSB5F60Li/zsQqi0nrMbgDvmOzDg1DGWiNgdStzLGMVWfKlTUp2Al77WNehqyr60Ag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793900006;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=0DjpnDmTLBwb0Qluwo4pY0uoN7St0QxG6Sq2VRXB7hU=;
	b=x4xIUpCntI975lVQfY4XJrLWC421v57BgyIOhcV0RabC1+PPMoBoL0UD5MtP6j7ciFar
	 PBunVBYfNXCdmAIcyPC6Qq3foIvdsgVYCsUJ2ax1tSoEL6GntQ291v68zppFQTlYGVioi
	 4mx8/qZ/YcN5f2uuoA7F7stshchk7JSgpcJLBqptTUZ0k/7mSLz/h4V7sQYYOFZ17GgWG
	 5Blt94RtfdewAmCUQJovCZ6V9EcZdBbfJDV53H82k9cRjvq6FCZwxqmM7UBoMy/gWBWIn
	 tDg1cdgf9hXWYtqKiLVKNgGiRB8524ugxs8omDgiIlwzZhuRyCHpwdsQTJvlwaUAxLw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Hl8zBgpd;
	arc=none smtp.remote-ip=74.125.82.173
Received: from mail-dy1-f173.google.com (mail-dy1-f173.google.com [74.125.82.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1012606A328
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 17:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F1012606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Hl8zBgpd
Received: by mail-dy1-f173.google.com with SMTP id 5a478bee46e88-36661f953e4so3056465eec.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 09:33:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793900005; x=1794504805; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=0DjpnDmTLBwb0Qluwo4pY0uoN7St0QxG6Sq2VRXB7hU=;
        b=Hl8zBgpdCIoWaoGQoYVGCjVPg5h7tjfSvjKAOmLw87rB/ZBeEm3Jra6B3hRuW7X+P1
         3+gcD+dbmXdsRRM8i5tlkeCYwjrsBeKXabliqzIpMdxnO7/vRzv8ExRDwNVxSqhkIB18
         K5ABxsUBoyuJLNP1N21c54tAM/o4NitjGmEtQ4qDjixYlDDKPAWXGQb5YWCeVzsFcQ2h
         XtKxqjM/pQs/qQmxFuHUohwnTgWoJfjrlkMjXslc30ZAD7QV+xMzyogfRYQBAySjxdI5
         5w+aZomT/z8yxIUl3GgMmqrAdpUHPIf695ZIWgpK8UKL8WcPDuAoy9KabmoJ4192skl3
         Telw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793900005; x=1794504805;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=0DjpnDmTLBwb0Qluwo4pY0uoN7St0QxG6Sq2VRXB7hU=;
        b=cI3i+nWhJeJvCnFvlq2e60ovF6S1djp7jK0tEwPWzaTzVr6012T0e5OIDrHm4olHfp
         bCZMpVgJS7CqLaki1I6KUfZGsTRtu8KgDdJWQcTZUgOUIdnekfmcSeE/EmdTz/EkCPPd
         bTR3hjoBTNiFfdQQ7R+MyJ3FZ6aH9hZjGUhl4ETbPeKL5fSJdHQxWLL7V5BJXbUPY47y
         2pwgVkN4bwLY4hpMx+M9OU/qKh4dcez3cxlHpW+MS0oNs7jN24YqP9QE0JWMTD1SFKdy
         CFaCPtziUC2QylpCg/6rg8NXyk/RtJdMoOUzSQrd6g8W+oYafH/mP/Wmo4pqlegyvH3G
         HQ7w==
X-Gm-Message-State: APuU4Z94WKCemOiqXpU/9Jj34YjHkcFVvZKxZ+Km/qY2YWiFrX9cD7Mh
	3RWmQSrB6eM1ZSmqbbFvoENpqXb59Su8viqPl4Z7wg823f22bJhzHZ8G
X-Gm-Gg: AYBFou0XJsrCJxUU4M+XDhbv4k3cqHqxVxFDgJ64FX5ANQpZU+ph1C5rR5arCWvqMF+
	z6d+r7By/esnHgEFHdD5JQ217FH/IzMyOAsl9IUvubsm0+2spRWPRYP6aFF1enKmppzUlC6zh/+
	AOqfm47/k6rVapiElP7d0pXVy31/04xAcKb//SXwbSqe+ie1DyRmadtXQ/gBT4P3Agce1qRIAni
	QN67IwPxftsCf9Fn903PZkK+zC+F5N50R2ffURMZbY2r2LO+Ss6QKWIg7N8NcBLrtZkVVBUbs3Q
	d1tV6DybY5kFZT0PMX0NxofwdcxsQP2ZXWjTdSxojtqRLJCx3RyIvesUVqXCJBtwtrinlZJ3YpH
	C6lH4IiBRJIVoKMAzvy0FhK9v23xWwbNzbWFs0+rGuzy3B2m9BVKCzKdP3NXR7Q9Ikt7QMvrViP
	7VylYiyt1BLolqeihka3WhQYfdhKNFdemxMcu2SOWppp0nGCIi8BB4dzbP00pwF/dsOJBIMOxbU
	Xdomnpu7pzMBJ1pcyw9Y19PJBkUFAXCZOmCJZR2Ju62+ipwt8mBzgygIkMEQ6BVe+J5SxZqWdzs
	LWQOPvIBwR1q+2/v1sM4a/WCFaAX
X-Received: by 2002:a05:693c:2802:b0:36a:1008:5815 with SMTP id 5a478bee46e88-36a4220407bmr26567580eec.5.1793900004587;
        Thu, 05 Nov 2026 09:33:24 -0800 (PST)
Received: from ubuntu.. ([2405:201:8026:213e:aef7:efba:dcd3:a664])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-36ca39c5f0csm16530514eec.29.2026.11.05.09.33.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Nov 2026 09:33:24 -0800 (PST)
From: mdshahid03@gmail.com
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Mohammad Shahid <mdshahid03@gmail.com>
Subject: [PATCH] NFS: idmap: fix race between key revocation and payload access
Date: Thu,  5 Nov 2026 23:02:51 +0530
Message-ID: <20261105173251.30389-1-mdshahid03@gmail.com>
X-Mailer: git-send-email 2.43.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mohammad Shahid <mdshahid03@gmail.com>

NFS idmapping retrieves the user key payload after validating the
key, but does not hold key semaphore while accessing the
payload.

The key revocation path acquires the key semaphore for writing
and clears the payload pointer through user_revoke().

Without holding the semaphore ,revocation can race with payload
access.In this case,user_key_payload_rcu can return NULL.

The existing IS_ERR_OR_NULL() check passes this NULL pointer to
PTR_ERR(),which returns zero and incoorectly reports scuccess.

Protect key validation and payload access with key semaphore
and use user_key_payload_locked() while holding the read lock.
Handle a NULL payload explicitly as revoked key.

This prevents concurrent revocation from changing the payload
while NFS is accessing it.

This issue is reported by smatch as possible NULL argunments to
PTR_ERR().

Signed-off-by: Mohammad Shahid <mdshahid03@gmail.com>
---
 fs/nfs/nfs4idmap.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index bc397110d977..06b193722660 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -317,16 +317,16 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		goto out;
 	}
 
-	rcu_read_lock();
 	rkey->perm |= KEY_USR_VIEW;
 
+	down_read(&rkey->sem);
 	ret = key_validate(rkey);
 	if (ret < 0)
 		goto out_up;
 
-	payload = user_key_payload_rcu(rkey);
-	if (IS_ERR_OR_NULL(payload)) {
-		ret = PTR_ERR(payload);
+	payload = user_key_payload_locked(rkey);
+	if (!payload) {
+		ret = -EKEYREVOKED;
 		goto out_up;
 	}
 
@@ -337,7 +337,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		ret = -EINVAL;
 
 out_up:
-	rcu_read_unlock();
+	up_read(&rkey->sem);
 	key_put(rkey);
 out:
 	return ret;
-- 
2.43.0

