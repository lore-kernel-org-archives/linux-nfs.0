Return-Path: <SRS0=YXm+=OP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED59BC04EB8
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 16:10:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B5E9520700
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 16:10:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OGFHW68m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5E9520700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726274AbeLFQKg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 6 Dec 2018 11:10:36 -0500
Received: from mail-oi1-f193.google.com ([209.85.167.193]:40455 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725871AbeLFQKg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Dec 2018 11:10:36 -0500
Received: by mail-oi1-f193.google.com with SMTP id t204so812601oie.7
        for <linux-nfs@vger.kernel.org>; Thu, 06 Dec 2018 08:10:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=zgpPntqUujWVWIJKPXkxnnw9byqObKXnABpMZw1mWtk=;
        b=OGFHW68m4yB/fu4jUl0wfcyR7TBu7l2sox9FHpHH7iZ8anwZ/h05f3QYu4u0pTmoeY
         jH3L+AdVBVypoG3XQ0GetJSydEVTVHxWxhUzcVEaboDYR5oLDTWGmH8FaLx0hcnXJvvG
         lwcXgTUDLzWsFWpU74LQQiPYqa17oqNS17mmZ91RjVIUkbzhwZF9xkItWirUj5wcMCQn
         0QZXv4cxeMnnuj2HfNgjFc8ZyIItgQLYhdrY897gm9zATsk4wkVyG59qjBtlGJPef1J9
         Ci1w6H6zrB9BxlYJFhpD4RygXBqfDrXKVUPFZADPyf8Ha6ABi1gtdi88KAHZgVxx7MLq
         Zpbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=zgpPntqUujWVWIJKPXkxnnw9byqObKXnABpMZw1mWtk=;
        b=AGHWltX7LUmzQV6DVADN7aTxALS4468SPkdLjV0z3pK09RxBbvryR2G6iX6K+7uWcE
         AodUWhefTBDdcf6yH9hcmFZewuI4CIOqV6kFIQWqTSpHMsnm7V3qeD6DOaZyA/50D6W4
         r1NW8V8x/rCvmiD8hKR2F+ccAmVzP203sUfl8SGZf1vhLgpGRSuCK9CIbtLotZwaqpAm
         hWsW4LO2Xobhjc/VuZpF173UjeHz4TUUeVV8L/Hwiek++Ay3sZyOq7KqrOGSx+E4lBVS
         T+aOlTk4EBBxutqsguqy/pGrC0HNXbVSFJia9jbsKj3s3fSM15bhWPe6rEQShqJjXcXV
         CD/g==
X-Gm-Message-State: AA+aEWYITPhtEIXngHN6i4YQsmTrg9prohz09xbKJFrbSscxo80oDWjV
        JNPpF/3AUUdxHti7o1POFC+fSuos
X-Google-Smtp-Source: AFSGD/X0PKwd5IqicHoIyGncvOgCeJtPafobvzvZ1b2bacOlWi5tiOgw6HWQX5RaKH4E6W/pw65ZyQ==
X-Received: by 2002:aca:4208:: with SMTP id p8mr18676172oia.331.1544112635196;
        Thu, 06 Dec 2018 08:10:35 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d5sm271426oth.78.2018.12.06.08.10.33
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Dec 2018 08:10:34 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4.2 fix async copy reboot recovery
Date:   Thu,  6 Dec 2018 11:10:36 -0500
Message-Id: <20181206161036.62673-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Original commit (e4648aa4f98a "NFS recover from destination server
reboot for copies") used memcmp() and then it was changed to use
nfs4_stateid_match_other() but that function returns opposite of
memcmp. As the result, recovery can't find the copy leading
to copy hanging.

Fixes: 80f42368868e ("NFSv4: Split out NFS v4.2 copy completion functions")
Fixes: cb7a8384dc02 ("NFS: Split out the body of nfs4_reclaim_open_state")
Signed-of-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d8decf2..f4f6373 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1560,7 +1560,7 @@ static void nfs42_complete_copies(struct nfs4_state_owner *sp, struct nfs4_state
 
 	spin_lock(&sp->so_server->nfs_client->cl_lock);
 	list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
-		if (nfs4_stateid_match_other(&state->stateid, &copy->parent_state->stateid))
+		if (!nfs4_stateid_match_other(&state->stateid, &copy->parent_state->stateid))
 			continue;
 		copy->flags = 1;
 		complete(&copy->completion);
-- 
1.8.3.1

