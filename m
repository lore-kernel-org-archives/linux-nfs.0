Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58654C282C3
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 18:12:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2953F218AF
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 18:12:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727991AbfAXSMC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 13:12:02 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:56354 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727664AbfAXSMC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Jan 2019 13:12:02 -0500
X-Greylist: delayed 2358 seconds by postgrey-1.27 at vger.kernel.org; Thu, 24 Jan 2019 13:12:02 EST
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gmirq-0004YI-7P
        for linux-nfs@vger.kernel.org; Thu, 24 Jan 2019 11:32:43 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 280B1801554; Thu, 24 Jan 2019 11:32:42 -0600 (CST)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Subject: Need help debugging NFS issues new to 4.20 kernel
Date:   Thu, 24 Jan 2019 11:32:42 -0600
Message-ID: <ufaimyearlx.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I could use some help figuring out the cause of some serious NFS client
issues I'm having with the 4.20.3 kernel which I did not see under
4.19.15.

I have a network of about 130 desktops (plus a bunch of other machines,
VMs and the like) running Fedora 29 connecting to six NFS servers
running CentOS 7.6 (with the heavily patched vendor kernel
3.10.0-957.1.3).  All machines involved are x86_64.  We use kerberized
NFS4 with generally sec=krb5i.  The exports are generally made with
"(rw,async,sec=krb5i:krb5p)".

Since I booted those clients into 4.20.3 I've started seeing processes
getting stuck in the D state.  The system itself will seem OK (except
for the high load average) as long as I don't touch the hung NFS mount.
Nothing was logged to dmesg or to the journal.  So far booting back into
the 4.19.15 kernel has cleared up the problem.  I cannot yet reproduce
this on demand; I've tried but it is probably related to some specific
usage pattern.

Has anyone else seen issues like this?  Can anyone help me to get more
useful information that might point to the problem?  I still haven't
learned how to debug NFS issues properly.  And if there's a stress test
tool I could easily run that might help to reproduce the issue, I'd be
happy to run it.

I note that 4.20.4 is out; I see one sunrpc fix which I guess could be
related (sunrpc: handle ENOMEM in rpcb_getport_async) but the systems
involved have plenty of free memory so I doubt that's it.  I'll
certainly try it anyway.

Various package versions:
kernel-4.20.3-200.fc29.x86_64 (the problematic kernel)
kernel-4.19.15-300.fc29.x86_64 (the functional kernel)
nfs-utils-2.3.3-1.rc2.fc29.x86_64
gssproxy-0.8.0-6.fc29.x86_64
krb5-libs-1.16.1-25.fc29.i686

Thanks in advance for any help or advice,

 - J<
