Return-Path: <SRS0=5zCG=DA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC62CC2D0A8
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Sep 2020 17:37:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 788E42065E
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Sep 2020 17:37:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="c6AMxWhT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726638AbgIWRhW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Sep 2020 13:37:22 -0400
Received: from us-smtp-delivery-124.mimecast.com ([63.128.21.124]:45318 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726498AbgIWRhW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2020 13:37:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1600882641;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=pdz9zJIsKhK20eDJMe62K7afKAWp0i6orrxBsn+rnUI=;
        b=c6AMxWhTJ+whos4lm1QyX9KJX+ClegPOUJQ3WYXorGi3BNT0VexEG++fAPrPAHKVa8tAmZ
        5fBNOPXiFQ8aE/11C+GAsaotqZkn5ZgJpJuyuy5WjoKyer3HP3WCTwa3O3kWNfivHpOIt8
        /XQIppp6dKIBENm2Qkv7m0mtp0JjLUs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-402-3LvReIskNfmL_SEopBcCKQ-1; Wed, 23 Sep 2020 13:37:19 -0400
X-MC-Unique: 3LvReIskNfmL_SEopBcCKQ-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id C18B71DE16;
        Wed, 23 Sep 2020 17:37:06 +0000 (UTC)
Received: from bcodding.csb (ovpn-64-66.rdu2.redhat.com [10.10.64.66])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8D91C5E7A3;
        Wed, 23 Sep 2020 17:37:06 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id 027F810C1261; Wed, 23 Sep 2020 13:37:06 -0400 (EDT)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2 v3] NFSv4: cleanup unused zero_stateid copy
Date:   Wed, 23 Sep 2020 13:37:05 -0400
Message-Id: <e226d7de6aadd3c709db683e8ca095c651b07226.1600882430.git.bcodding@redhat.com>
In-Reply-To: <cover.1600882430.git.bcodding@redhat.com>
References: <cover.1600882430.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since commit d9aba2b40de6 ("NFSv4: Don't use the zero stateid with
layoutget") the zero stateid will never be used.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4state.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4bf10792cb5b..06bbe19c8b2c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1018,18 +1018,14 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 bool nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
 	bool ret;
-	const nfs4_stateid *src;
 	int seq;
 
 	do {
 		ret = false;
-		src = &zero_stateid;
 		seq = read_seqbegin(&state->seqlock);
-		if (test_bit(NFS_OPEN_STATE, &state->flags)) {
-			src = &state->open_stateid;
+		if (test_bit(NFS_OPEN_STATE, &state->flags))
 			ret = true;
-		}
-		nfs4_stateid_copy(dst, src);
+		nfs4_stateid_copy(dst, &state->open_stateid);
 	} while (read_seqretry(&state->seqlock, seq));
 	return ret;
 }
-- 
2.20.1

