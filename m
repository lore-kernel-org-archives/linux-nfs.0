Return-Path: <SRS0=3Ktc=WJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC5FCC433FF
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Aug 2019 16:05:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8DF9F20651
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Aug 2019 16:05:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728327AbfHMQF2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Aug 2019 12:05:28 -0400
Received: from mx1.math.uh.edu ([129.7.128.32]:50814 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728321AbfHMQF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Aug 2019 12:05:27 -0400
X-Greylist: delayed 3391 seconds by postgrey-1.27 at vger.kernel.org; Tue, 13 Aug 2019 12:05:27 EDT
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx1.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1hxYPv-0000RG-LW
        for linux-nfs@vger.kernel.org; Tue, 13 Aug 2019 10:08:56 -0500
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 91176801554; Tue, 13 Aug 2019 10:08:55 -0500 (CDT)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Subject: Regression in 5.1.20: Reading long directory fails
Date:   Tue, 13 Aug 2019 10:08:55 -0500
Message-ID: <ufak1bhyuew.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A user reported to me that they couldn't see the entirety of their home
directory.  And indeed:

[root@ld00 ~]# ls -l ~dblecher|wc -l
ls: reading directory '/home/dblecher': Input/output error
1844
[root@ld00 ~]# cat /proc/version Linux version 5.1.20-300.fc30.x86_64 (mockbuild@bkernel04.phx2.fedoraproject.org) (gcc version 9.1.1 20190503 (Red Hat 9.1.1-1) (GCC)) #1 SMP Fri Jul 26 15:03:11 UTC 2019

Mount options are: nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5i
The server is running CentOS 7 (kernel 3.10.0-957.12.2.el7.x86_64).

The problem does not appear in 5.1.19 and all 7657 entries in that
directory are returned.

Looking at the 5.1.20 changelog I see a few NFS-related changes but
commit 3536b79ba75ba44b9ac1a9f1634f2e833bbb735c:
  Revert "NFS: readdirplus optimization by cache mechanism" (memleak)
stands out; I'm working on building a kernel with the revert reverted.

Note that this doesn't happen on any directory with lots of files; I've
only managed to see it on this particular user's overly large home
directory.  So I can trivially reproduce it but I don't know how anyone
else could.  I'm happy to collect any debugging data that might be
needed.

 - J<
