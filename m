Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B45DDC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:49:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8BF9920657
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:49:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727532AbfCKPtw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 11:49:52 -0400
Received: from mx1.redhat.com ([209.132.183.28]:33474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727519AbfCKPtv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 11:49:51 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CC5723680A;
        Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B0DAE60863;
        Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 33C9A214F8; Mon, 11 Mar 2019 11:49:51 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 0/3] a few fixes
Date:   Mon, 11 Mar 2019 11:49:48 -0400
Message-Id: <20190311154951.6144-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The first patch fixes bogus DESTROY_SESSION and DESTROY_CLIENTID ops
being sent to the server.  The other two prevent session and client
records from hanging around on the server.

Scott Mayhew (3):
  nfs4.1: don't cache sessionids and clientids after destroying
  nfs4.1: clean up the session and client created in
    Environment.finish()
  nfs4.1: close the file created in SEQ10b

 nfs4.1/server41tests/environment.py | 4 ++++
 nfs4.1/server41tests/st_sequence.py | 5 ++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

-- 
2.17.2

