Return-Path: <SRS0=y/Bv=UD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFAAEC282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Jun 2019 12:41:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3A6724B95
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Jun 2019 12:41:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727664AbfFDMlJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Jun 2019 08:41:09 -0400
Received: from mx1.redhat.com ([209.132.183.28]:35752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727654AbfFDMlI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jun 2019 08:41:08 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7C74CA9DB4;
        Tue,  4 Jun 2019 12:41:06 +0000 (UTC)
Received: from [10.10.66.2] (ovpn-66-2.rdu2.redhat.com [10.10.66.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 0FB0210027C2;
        Tue,  4 Jun 2019 12:41:03 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Cc:     "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: client skips revalidation if holding a delegation
Date:   Tue, 04 Jun 2019 08:41:03 -0400
Message-ID: <6C2EF3B8-568A-41F0-B134-52996457DD7D@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 04 Jun 2019 12:41:08 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hey linux-nfs, and especially maintainers,

I'm still interested in working on a problem raised a couple weeks ago, but
confusion muddled that discussion and it died:

If the client holds a read delegation, it will skip revalidation of a dentry
in lookup.  If the file was moved on the server, the client can end up with
two positive dentries in cache for the same inode, and the dentry that
doesn't exist on the server will never time out of the cache.

The client can detect this happening because the directory of the dentry
that should be revalidated updates it's change attribute.  Skipping
revalidation is an optimization in the case we hold a delegation, but this
optimization should only be used when the delegation was obtained via a
lookup of the dentry we are currently revalidating.

Keeping the optimization might be done by tying the delegation to the
dentry.  Lacking some (easy?) way to do that currently, it seems simpler to
remove the optimization altogether, and I will send a patch to remove it.

Any thoughts on this?  Any response, even asserting that this is not something
we will fix are welcome.

Thanks,
Ben
