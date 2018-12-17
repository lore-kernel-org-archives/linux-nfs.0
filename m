Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1CACC43612
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:56:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C964A2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:56:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387766AbeLQP4s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 10:56:48 -0500
Received: from mxout3.mail.janestreet.com ([38.105.200.229]:55628 "EHLO
        mxout3.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727833AbeLQP4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 10:56:47 -0500
X-JS-Received: from [30.40.81.8] (helo=tot-qpr-mailcore1)
        by mxout3.mail.janestreet.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.90_1)
        (envelope-from <cperl@janestreet.com>)
        id 1gYvGA-0008MX-N9
        for linux-nfs@vger.kernel.org; Mon, 17 Dec 2018 10:56:46 -0500
X-JS-Flow: external
X-JS-Scanner-attachment: No attachments
X-JS-Scanner-esets: Not scanned (internal mail)
X-JS-Received: by tot-qpr-mailcore1 with ocaml/mailcore/main_production (71f307ccacc9)
        (envelope-from <cperl@janestreet.com>)
        id BcF8c--M6jmcA-Rf; 2018-12-17 10:56:46.608495-05:00
X-JS-Received: by igm-qpr-mailgw2 with ocaml/mailcore/main_gateway (1e9cb192eda3)
        (envelope-from <cperl@janestreet.com>)
        id BcF8c--M9XcgA-RK; 2018-12-17 10:56:46.551270-05:00
X-JS-Received: from cperl by igm-qws-u12114b.delacy.com with local (Exim 4.91)
        (envelope-from <cperl@janestreet.com>)
        id 1gYvGA-00084c-Ga; Mon, 17 Dec 2018 10:56:46 -0500
From:   Chris Perl <cperl@janestreet.com>
To:     linux-nfs@vger.kernel.org
Cc:     Chris Perl <cperl@janestreet.com>
Subject: [PATCH V2 0/1] Fix incorrect sharing of AUTH_SYS and AUTH_GSS_KRB5 data structures
Date:   Mon, 17 Dec 2018 10:56:37 -0500
Message-Id: <20181217155638.30975-1-cperl@janestreet.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-JS-Region: Americas
X-JS-Processed-by: mailcore
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've marked this as V2, even though it is really the same exact patch
as last time.  The only change is the addition of a Signed-off-by in
the commit message.  Original email below.

Hi!

I explained most of the details in the commit, but the gist is that
mounts that don't have an explicit `sec' option passed will never get
through the first part of the if statement I removed, meaning a mount
which has its auth flavor discovered at mount time (e.g. in
`nfs_try_mount_request') cannot pass that test.

This means auth flavors are not compared and can lead to incorrect
sharing of data structures via `nfs_fs_mount_common'.

I am not the most familiar with all this code, so I might be missing
something about why that check is needed.  Please correct me if it
needs to remain.

In addition to testing this patch on a real system I tested something
almost equivalent to this patch by using systemtap to force
`b->auth_info.flavor_len' to 1 on every invocation if it was 0 (so the
if would always succeed) and back to 0 on exit.  Doing both of these
things caused my issues to go away and helped to reinforce my notion
that this was the right fix.

In case you're interested, that script is below.  Note that it hooks
onto `nfs_compare_super' and not `nfs_compare_mount_options' because
the latter is inlined.

Please copy me directly on any replies, as I'm not a member of the
list.

global revert;

probe module("nfs").function("nfs_compare_super").call
{
	server = @cast($data, "struct nfs_sb_mountdata")->server;
	if (server->auth_info->flavor_len == 0) {
	   server->auth_info->flavor_len = 1;
	   				 revert = 1;
					 }
}

probe module("nfs").function("nfs_compare_super").return
{
	server = @cast($data, "struct nfs_sb_mountdata")->server;
	if (revert) {
	   revert = 0;
	   	  server->auth_info->flavor_len = 0;
		  }
}

Chris Perl (1):
  NFS: nfs_compare_mount_options always compare auth flavors.

 fs/nfs/super.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

-- 
2.17.1

