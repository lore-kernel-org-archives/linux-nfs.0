Return-Path: <SRS0=7k0R=WS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B486EC3A5A1
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Aug 2019 19:39:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 89648233FC
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Aug 2019 19:39:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732838AbfHVTja (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 22 Aug 2019 15:39:30 -0400
Received: from mx2.math.uh.edu ([129.7.128.33]:51826 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726319AbfHVTj3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Aug 2019 15:39:29 -0400
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1i0sve-0004Tw-Mp; Thu, 22 Aug 2019 14:39:28 -0500
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 9C2EF801554; Thu, 22 Aug 2019 14:39:26 -0500 (CDT)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Cc:     km@cm4all.com, linux-kernel@vger.kernel.org
Subject: Re: Regression in 5.1.20: Reading long directory fails
References: <ufak1bhyuew.fsf@epithumia.math.uh.edu>
Date:   Thu, 22 Aug 2019 14:39:26 -0500
In-Reply-To: <ufak1bhyuew.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Tue, 13 Aug 2019 10:08:55 -0500")
Message-ID: <ufapnkxkn0x.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I now have another user reporting the same failure of readdir on a long
directory which showed up in 5.1.20 and was traced to
3536b79ba75ba44b9ac1a9f1634f2e833bbb735c.  I'm not sure what to do to
get more traction besides reposting and adding some addresses to the CC
list.  If there is any information I can provide which might help to get
to the bottom of this, please let me know.

To recap:

5.1.20 introduced a regression reading some large directories.  In this
case, the directory should have 7800 files or so in it:

[root@ld00 ~]# ls -l ~dblecher|wc -l
ls: reading directory '/home/dblecher': Input/output error
1844
[root@ld00 ~]# cat /proc/version Linux version 5.1.20-300.fc30.x86_64 (mockbuild@bkernel04.phx2.fedoraproject.org) (gcc version 9.1.1 20190503 (Red Hat 9.1.1-1) (GCC)) #1 SMP Fri Jul 26 15:03:11 UTC 2019

(The server is a Centos 7 machine running kernel 3.10.0-957.12.2.el7.x86_64.)

Building a kernel which reverts commit 3536b79ba75ba44b9ac1a9f1634f2e833bbb735c:
  Revert "NFS: readdirplus optimization by cache mechanism" (memleak)
fixes the issue, but of course that revert was fixing a real issue so
I'm not sure what to do.

I can trivially reproduce this by simply trying to list the problematic
directories but I'm not sure how to construct such a directory; simply
creating 10000 files doesn't cause the problem for me.  I am willing to
test patches and can build my own kernels, and I'm happy to provide any
debugging information you might require.  Unfortunately I don't know
enough to dig in and figure out for myself what's going wrong.

I did file https://bugzilla.redhat.com/show_bug.cgi?id=1740954 just to
have this in a bug tracker somewhere.  I'm happy to file one somewhere
else if that would help.

 - J<
