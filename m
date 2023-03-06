Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BC69C64EC4
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Mar 2023 15:45:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231447AbjCFPpP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Mar 2023 10:45:15 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51504 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231481AbjCFPpL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Mar 2023 10:45:11 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5BEB7366B1
        for <linux-nfs@vger.kernel.org>; Mon,  6 Mar 2023 07:44:40 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 6F9F5B80EC1
        for <linux-nfs@vger.kernel.org>; Mon,  6 Mar 2023 15:43:50 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD876C433EF;
        Mon,  6 Mar 2023 15:43:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1678117429;
        bh=klbdhgsDUrD6yHoRC4sqEVssKJ2F6vWM/oyBR2QY788=;
        h=Subject:From:To:Cc:Date:From;
        b=CPxwsc1sDglRStnuB4C27MzrzIcNmkJqVKLQJz0/Nk8QZga9kSzT7PJIKd9PCVTS4
         nUtywjU7KOegVpHf3QemZDp/IqfzRLAsipMpnapW2uY/6BV/6cMLB29wamIY9vNEF6
         bFwdjF4mkeoUk0nxtOOi5r/ARAyO72UKJEeOs1VxdC+Ab3T+b0iaHnWRXx1oHw3rno
         9goa3D2QsFgTuSUxTPuMJONG9qll22+V4EabqYI/DVISMzXDjuxwInUikpnmR0wQUn
         cXDhT6Br20IspcHdBxtiYPmsbyoEh1iD9EK0dT8jzIr5yQWfjFVJ+sc/oIxLexFmWO
         aoF0oO2uSohRw==
Subject: [PATCH] NFSD: Protect against filesystem freezing
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     jack@suse.de, flole@flole.de
Date:   Mon, 06 Mar 2023 10:43:47 -0500
Message-ID: <167811742782.1909.380332356774647144.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Flole observes this WARNING on occasion:

[1210423.486503] WARNING: CPU: 8 PID: 1524732 at fs/ext4/ext4_jbd2.c:75 ext4_journal_check_start+0x68/0xb0

Reported-by: <flole@flole.de>
Suggested-by: Jan Kara <jack@suse.cz>
Link: https://bugzilla.kernel.org/show_bug.cgi?id=217123
Fixes: 73da852e3831 ("nfsd: use vfs_iter_read/write")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/vfs.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 21d5209f6e04..ba34a31a7c70 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1104,7 +1104,9 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfsd_file *nf,
 	since = READ_ONCE(file->f_wb_err);
 	if (verf)
 		nfsd_copy_write_verifier(verf, nn);
+	file_start_write(file);
 	host_err = vfs_iter_write(file, &iter, &pos, flags);
+	file_end_write(file);
 	if (host_err < 0) {
 		nfsd_reset_write_verifier(nn);
 		trace_nfsd_writeverf_reset(nn, rqstp, host_err);


