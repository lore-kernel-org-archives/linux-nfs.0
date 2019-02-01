Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91AA7C282D8
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 14:28:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A2AD218AC
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 14:28:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728014AbfBAO2r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 09:28:47 -0500
Received: from nautica.notk.org ([91.121.71.147]:42850 "EHLO nautica.notk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726172AbfBAO2r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Feb 2019 09:28:47 -0500
Received: by nautica.notk.org (Postfix, from userid 1001)
        id 92BDEC009; Fri,  1 Feb 2019 15:28:45 +0100 (CET)
Date:   Fri, 1 Feb 2019 15:28:30 +0100
From:   Dominique Martinet <asmadeus@codewreck.org>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org
Subject: NFSv4 i_blocks=0 immediately after creating a file (Was:
 inode_add/set_bytes and i_blocks, dangerous for small files?)
Message-ID: <20190201142830.GA2177@nautica>
References: <20190125140229.GA5119@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190125140229.GA5119@nautica>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Following up on this for NFS as I made a sneaky bug report hard to
notice, this might be worth having a look:

Dominique Martinet wrote on Fri, Jan 25, 2019:
> [...] There is a small, few seconds window
> where I can reproduce a similar issue on nfs:
> $ echo foo > bar; stat -c %b bar; sleep 3; stat -c %b bar
> 0
> 8
> with a 4.14.87 knfsd and 4.19.15-300.fc29 client, nfs 4.2, both x86_64,
> no export option or explicit client option.

In other words, the file's i_blocks isn't updated for a short while on
nfs v4 which might lead to data loss (see previous email for example
e.g. tar), just create a file and immediately stat to notice.


nfs v3 doesn't exhibit the problem.

I also wasn't able to reproduce on the 4.14.87 machine as a and nfs v4
client so it's likely a semi-recent regression, I could probably bissect
it if really required but I'm sure someone here has some dedicated
hardware for this better than my laptop :)


Feel free to ask if you cannot reproduce and I'll try updating to master
on both client and server just in case.

Thanks,
-- 
Dominique
