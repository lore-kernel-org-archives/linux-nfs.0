Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D82ADC10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 13:37:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AF2E520693
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 13:37:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389053AbfDRNh2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 09:37:28 -0400
Received: from mx1.redhat.com ([209.132.183.28]:51144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388907AbfDRNh2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 09:37:28 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id ADFE2C075D79
        for <linux-nfs@vger.kernel.org>; Thu, 18 Apr 2019 13:37:28 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-121-236.rdu2.redhat.com [10.10.121.236])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 94A9A19C58
        for <linux-nfs@vger.kernel.org>; Thu, 18 Apr 2019 13:37:28 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 4444C20F54; Thu, 18 Apr 2019 09:37:28 -0400 (EDT)
Date:   Thu, 18 Apr 2019 09:37:28 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     linux-nfs@vger.kernel.org
Subject: Question about open(CLAIM_FH)
Message-ID: <20190418133728.GS3773@coeurl.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 18 Apr 2019 13:37:28 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the client does an open(CLAIM_FH) and the server already has open
state for that open owner and file, what's supposed to happen?
Currently the server returns the existing stateid with the seqid bumped,
but it looks like the client is expecting a new stateid (I'm seeing the
state manager spending a lot of time waiting in
nfs_set_open_stateid_locked() due to NFS_STATE_CHANGE_WAIT being set in
the state flags by nfs_need_update_open_stateid()).

Looking at rfc5661 section 18.16.3, I see:

   | CLAIM_NULL, CLAIM_FH | For the client, this is a new OPEN request |
   |                      | and there is no previous state associated  |
   |                      | with the file for the client.  With        |
   |                      | CLAIM_NULL, the file is identified by the  |
   |                      | current filehandle and the specified       |
   |                      | component name.  With CLAIM_FH (new to     |
   |                      | NFSv4.1), the file is identified by just   |
   |                      | the current filehandle.  

So it seems like maybe the server should be tossing the old state and
returning a new stateid?

-Scott
