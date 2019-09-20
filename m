Return-Path: <SRS0=tV5x=XP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17581C49ED7
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Sep 2019 11:26:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E224B205F4
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Sep 2019 11:26:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PjKwDKm+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2438183AbfITL0J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Sep 2019 07:26:09 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:38078 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2438179AbfITL0J (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Sep 2019 07:26:09 -0400
Received: by mail-io1-f66.google.com with SMTP id k5so15323324iol.5
        for <linux-nfs@vger.kernel.org>; Fri, 20 Sep 2019 04:26:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=owbPNNcxjT5XKu6v3G4mEstWx8051g6tPkh8ytztNTM=;
        b=PjKwDKm+lJ+INL5UyfnAazw67cMh9yPkm/RdguHN9f4rM1zpgowAlaVB6je9g2PRoR
         8Ea4t36qjhqrTpY2od8aESP6+/CeYEmzpZkK1wsM1ttTW+2SL6yix8m+5kWGgXyYBbrJ
         7P/Xxi+jaSckQmYS9rOugQULhjKVh5gMnGQmIeV4bb9EtkUM6rFlvbgRHCobmGEpPndN
         lPGHQCbapzT6Z36OBx8b6jboMvjeVtpwqWCoooByeFQNGAhHTCWRwh7mbU57xkGtzaQa
         va/Cu1229qZH3TPpI/Qy4SUxKAZE3ZYtMboS6fNh5A+Jhxvc04L0FVD+Uw9i8TXRKC12
         sGIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=owbPNNcxjT5XKu6v3G4mEstWx8051g6tPkh8ytztNTM=;
        b=WZokM3t276JvM8Zng4ATVajpsZ8W8zuJjezzHcUQy0eb9nsxElFVPrKOj+rk+HqZLD
         0wT0awQDIHxcQhhjAeaa1VxfKyBzybtObLkT/rdPiLV2EZblhOnPQE+vh2J31nWNbj63
         s048SQGn7aMkCZDEoryo722NL9DqpgUy0RoTN0vUGJC3Izuy8lmhvma9HaUMlR36N/HR
         StiNfjm/h7Y0CpsCgKlEkgKulR9cajCrKQ4nJtKACgW8SU2/DmSPfxXGNxlSmWE7wXYU
         kM4ek9oEexEs8q3fTXXKQ6y4c5q3byB4tyl6/Zl6rMpsalSJCdOln3eeFI7FRXTSV6Fj
         WlKw==
X-Gm-Message-State: APjAAAUMBhaAZDGo4JRHman0F3UvWYH0W04w9/zXqCM0aGYI4DKjnPvr
        5D3axMrJDgZpSfQSuJtTvDkjiziTVw==
X-Google-Smtp-Source: APXvYqyJFLFTxlbVd25afJJ7UL2daRSlLy1DBgGpbvRkQsQHLZDaIFtTseWjSeLHQCreEklp49YCzA==
X-Received: by 2002:a6b:c9d7:: with SMTP id z206mr11007377iof.172.1568978768110;
        Fri, 20 Sep 2019 04:26:08 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id q74sm1308736iod.72.2019.09.20.04.26.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Sep 2019 04:26:07 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     Olga Kornievskaia <aglo@umich.edu>, linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/9] NFSv4: Add a helper to increment stateid seqids
Date:   Fri, 20 Sep 2019 07:23:44 -0400
Message-Id: <20190920112348.69496-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190920112348.69496-5-trond.myklebust@hammerspace.com>
References: <20190920112348.69496-1-trond.myklebust@hammerspace.com>
 <20190920112348.69496-2-trond.myklebust@hammerspace.com>
 <20190920112348.69496-3-trond.myklebust@hammerspace.com>
 <20190920112348.69496-4-trond.myklebust@hammerspace.com>
 <20190920112348.69496-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a helper function to increment stateid seqids according to the
rules specified in RFC5661 Section 8.2.2.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4_fs.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3564da1ba8a1..e8f74ed98e42 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -574,6 +574,15 @@ static inline bool nfs4_stateid_is_newer(const nfs4_stateid *s1, const nfs4_stat
 	return (s32)(be32_to_cpu(s1->seqid) - be32_to_cpu(s2->seqid)) > 0;
 }
 
+static inline void nfs4_stateid_seqid_inc(nfs4_stateid *s1)
+{
+	u32 seqid = be32_to_cpu(s1->seqid);
+
+	if (++seqid == 0)
+		++seqid;
+	s1->seqid = cpu_to_be32(seqid);
+}
+
 static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 {
 	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
-- 
2.21.0

