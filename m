Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07E75C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 17:41:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CDBB620673
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 17:41:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDBB620673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727047AbeLAEvx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 23:51:53 -0500
Received: from mx1.redhat.com ([209.132.183.28]:32804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726650AbeLAEvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 23:51:53 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DD87C30CFF45;
        Fri, 30 Nov 2018 17:41:51 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-120-28.rdu2.redhat.com [10.10.120.28])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9282161F2E;
        Fri, 30 Nov 2018 17:41:51 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 1B2642076C; Fri, 30 Nov 2018 12:41:51 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: deal with v4.0 servers that request confirmation on reclaim-type opens
Date:   Fri, 30 Nov 2018 12:41:51 -0500
Message-Id: <20181130174151.19448-2-smayhew@redhat.com>
In-Reply-To: <20181130174151.19448-1-smayhew@redhat.com>
References: <20181130174151.19448-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 30 Nov 2018 17:41:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There are some NFS v4.0 servers that request confirmation on
reclaim-type opens even though it is disallowed by RFC 7530.

The Linux NFS client used to cope with those okay due to
1) nfs4_opendata_alloc() setting the filehandle in the args for the
OPEN_CONFIRM to point to the filehandle in the OPEN results, and
2) nfs4_open_prepare() copying the filehandle from the OPEN args to the
OPEN results when doing an open by filehandle

The latter part was removed by commit 4e2fcac77390 ("nfsv4: Use correct
inode in _nfs4_opendata_to_nfs4_state()")... and since there's no GETFH
in the OPEN compound when doing a reclaim-type open, if one of these
servers does request confirmation we wind up sending a zero filehandle
in the PUTFH of the OPEN_CONFIRM compound and the OPEN_CONFIRM fails
with NFS4ERR_BADHANDLE, causing the reclaim to fail.

Add the copying of the filehandle back to nfs4_open_prepare() and
log a warning in the event that the client does get a reply to
OPEN(CLAIM_PREVIOUS) that has NFS4_OPEN_RESULT_CONFIRM set.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/nfs4proc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 867457d6dfbe..5e521a506da3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2323,6 +2323,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		/* Fall through */
 	case NFS4_OPEN_CLAIM_FH:
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
+		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
 	if (nfs4_setup_sequence(data->o_arg.server->nfs_client,
@@ -2470,8 +2471,14 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 
 	nfs_fattr_map_and_free_names(NFS_SERVER(dir), &data->f_attr);
 
-	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM)
+	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
+		if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS)
+			pr_err_ratelimited("NFS: Broken NFSv4 server %s is "
+					"requesting open confirmation for "
+					"OPEN(CLAIM_PREVIOUS)\n",
+					NFS_SERVER(dir)->nfs_client->cl_hostname);
 		status = _nfs4_proc_open_confirm(data);
+	}
 
 	return status;
 }
-- 
2.17.1

