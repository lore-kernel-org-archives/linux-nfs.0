Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3E0CC433E0
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Feb 2021 17:25:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9DE5364DE9
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Feb 2021 17:25:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229705AbhBGRZc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Feb 2021 12:25:32 -0500
Received: from outbound-mail-qk39.uniserve.ca ([204.239.30.184]:22825 "EHLO
        outbound-mail-qk39.uniserve.ca" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S229506AbhBGRZ2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2021 12:25:28 -0500
X-Greylist: delayed 398 seconds by postgrey-1.27 at vger.kernel.org; Sun, 07 Feb 2021 12:25:28 EST
Received: from uniserve.com (<unknown> [204.239.30.179])
        by outbound-mail-qk39.uniserve.ca (OpenSMTPD) with ESMTPS id 5bf4cc33 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <linux-nfs@vger.kernel.org>;
        Sun, 7 Feb 2021 09:18:01 -0800 (PST)
X-Default-Received-SPF: pass (skip=loggedin (res=PASS)) x-ip-name=50.92.153.236; envelope-from=<sn0297@sunshine.net>;
Received: from [192.168.8.240] (unverified [50.92.153.236]) 
        by uniserve.com (SurgeMail 7.4c) with ESMTP (TLS) id 47655965-1392368 
        for <linux-nfs@vger.kernel.org>; Sun, 07 Feb 2021 09:18:01 -0800
Message-ID: <602020C9.50705@sunshine.net>
Date:   Sun, 07 Feb 2021 09:18:01 -0800
From:   Rue Mohr <sn0297@sunshine.net>
User-Agent: Mozilla/5.0 (X11; Linux i686; rv:10.0.4) Gecko/20120510 Icedove/10.0.4
MIME-Version: 1.0
To:     linux-nfs@vger.kernel.org
Subject: nfs kernel server bug
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
X-Authenticated-User: sn0297@uniserve.com 
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


I'm having an issue where the kernel server is dishing out all zeros for file content being read over NFS. The file byte 
count is correct.
Writing files is fine.
With the same client, a different server works just fine.

I have been trying to pin this down, so far all I know is that the packets from the server actually contain zeros for 
the file contents.

The troubled server kernel is 5.4.1

Has anyone encountered this or is it just me?


