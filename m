Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E96C3C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AEDE22186A
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727467AbfCNVML (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from mx1.redhat.com ([209.132.183.28]:55322 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727309AbfCNVML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 609D4C0B6144;
        Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2AADB19C56;
        Thu, 14 Mar 2019 21:12:10 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 7CF66213F8; Thu, 14 Mar 2019 17:12:10 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 0/4] nfs4.1: add a bunch of reboot tests
Date:   Thu, 14 Mar 2019 17:12:06 -0400
Message-Id: <20190314211210.7454-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

(Note: These patches go on top of "nfs4.1: clean up the session and
client created in Environment.init()" from Jeff Layton sent on March
14th).

These patches add the following reboot tests:

REBT2x: Server reboot with N clients reclaiming opens.
REBT3x: Server reboot with N clients reclaming opens.  Server reboots
        again after half the clients have reclaimed.
REBT4x: Server reboot with N clients reclaiming opens.  Half the
        clients attempt to reclaim twice.
(where x in {a, b, c}, with 'a' using 10 clients, 'b' using 100 clients,
and 'c' testing 1000 clients)
REBT5:  Server reboot where the client starts reclaiming shortly before
        the end of grace.

Note all of these tests require the use of a helper script or manual
intervention to restart the server.

Scott Mayhew (4):
  nfs4.1: add some reboot tests
  nfs4.1: add some more reboot tests
  nfs4.1: still more reboot tests
  nfs4.1: test delayed reclaim following a server reboot

 nfs4.1/server41tests/st_reboot.py | 284 +++++++++++++++++++++++++++++-
 1 file changed, 278 insertions(+), 6 deletions(-)

-- 
2.17.2

