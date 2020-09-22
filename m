Return-Path: <SRS0=wC6f=C7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDE59C4727E
	for <linux-nfs@archiver.kernel.org>; Tue, 22 Sep 2020 10:14:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A7A27238D6
	for <linux-nfs@archiver.kernel.org>; Tue, 22 Sep 2020 10:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="PkWa/BTN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726518AbgIVKOU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 22 Sep 2020 06:14:20 -0400
Received: from us-smtp-delivery-124.mimecast.com ([63.128.21.124]:24124 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726549AbgIVKOU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2020 06:14:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1600769659;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=VqkLDsFVfcY0BjNaoOnDMsuIzRKX+fGkLaqAnNh0Qlo=;
        b=PkWa/BTNwo6nxLtPGJqZN/FG1XHYdSbu8do1mDq4PP31vEF0V9xMzWWlgCqQNXjgR3r4DL
        IeI05nUgzpOd4yLt5k8VOMVjDcKVKH2icZV9dQOgI+zHcQQyx8AHvhIb4qM5x0jLFgIKL8
        L4UleYyJ8jLAu7cbt+vCGYrTohBYsYg=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-56-MgsFduACMtyrmRdaTZ3uIw-1; Tue, 22 Sep 2020 06:14:12 -0400
X-MC-Unique: MgsFduACMtyrmRdaTZ3uIw-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id DA04A80734E;
        Tue, 22 Sep 2020 10:14:10 +0000 (UTC)
Received: from bcodding.csb (ovpn-64-66.rdu2.redhat.com [10.10.64.66])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9DB587366B;
        Tue, 22 Sep 2020 10:14:10 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id 2853E10C311B; Tue, 22 Sep 2020 06:14:10 -0400 (EDT)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/3 v2] NFSv4: Refactor nfs_need_update_open_stateid()
Date:   Tue, 22 Sep 2020 06:14:10 -0400
Message-Id: <83ddf146946030e75d1ca1f848e7416645437767.1600769543.git.bcodding@redhat.com>
In-Reply-To: <d6c4cd73c3546057edfe8d80512b274bb431d68e.1600686204.git.bcodding@redhat.com>
References: <5a7f6bbf4cf2038634a572f42ad80e95a8d0ae9c.1600686204.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The logic was becoming difficult to follow.  Add some comments and local
variables to clarify the behavior.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9ced7a62c05e..827659ee1fad 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1568,22 +1568,25 @@ static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
 static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *stateid)
 {
-	if (test_bit(NFS_OPEN_STATE, &state->flags) == 0 ||
-	    !nfs4_stateid_match_other(stateid, &state->open_stateid)) {
-		if (stateid->seqid == cpu_to_be32(1)) {
+	bool state_matches_other = nfs4_stateid_match_other(stateid, &state->open_stateid);
+	bool seqid_one = stateid->seqid == cpu_to_be32(1);
+
+	if (test_bit(NFS_OPEN_STATE, &state->flags)) {
+		/* The common case - we're updating to a new sequence number */
+		if (state_matches_other && nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
+			nfs_state_log_out_of_order_open_stateid(state, stateid);
+			return true;
+		}
+	} else {
+		/* This is the first OPEN */
+		if (!state_matches_other && seqid_one) {
 			nfs_state_log_update_open_stateid(state);
-		} else {
-			if (!nfs4_stateid_match_other(stateid, &state->open_stateid))
-				return false;
-			else
-				set_bit(NFS_STATE_CHANGE_WAIT, &state->flags);
+			return true;
+		}
+		if (!state_matches_other && !seqid_one) {
+			set_bit(NFS_STATE_CHANGE_WAIT, &state->flags);
+			return true;
 		}
-		return true;
-	}
-
-	if (nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
-		nfs_state_log_out_of_order_open_stateid(state, stateid);
-		return true;
 	}
 	return false;
 }
-- 
2.20.1

