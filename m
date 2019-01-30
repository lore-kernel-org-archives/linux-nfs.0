Return-Path: <SRS0=/R4e=QG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A33BC282D5
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 09:03:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0495E20870
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 09:03:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727500AbfA3JD3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 30 Jan 2019 04:03:29 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60384 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725850AbfA3JD3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Jan 2019 04:03:29 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E42C489AEF;
        Wed, 30 Jan 2019 09:03:28 +0000 (UTC)
Received: from [10.10.120.47] (ovpn-120-47.rdu2.redhat.com [10.10.120.47])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 1AC785D96F;
        Wed, 30 Jan 2019 09:03:27 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Always return the error that truncates a flushing
 page
Date:   Wed, 30 Jan 2019 09:03:25 +0000
Message-ID: <78609F05-A4E4-4C6C-98A4-BF65F6E9161C@redhat.com>
In-Reply-To: <3B6A83BD-9BCB-41CD-9624-AB1158A5CB24@redhat.com>
References: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
 <9fc3d4ee7d8eafdfdb7b7c1397ecb25dd22e12b7.camel@hammerspace.com>
 <4512E750-0B6F-4842-B7B8-469FF04FBB00@redhat.com>
 <e87423e25a6aeff640199eb1a776194cfef8a041.camel@hammerspace.com>
 <3B6A83BD-9BCB-41CD-9624-AB1158A5CB24@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 30 Jan 2019 09:03:29 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 29 Jan 2019, at 22:34, Benjamin Coddington wrote:
> You're right.  I did
>
> # git describe c373fff7bd25
> v4.11-rc7-70-gc373fff7bd25
>
> .. and assumed it ended up in v4.11.  I wonder what actually happened to
> it, I'll see if I can find out.

git describe is giving me the closest ancestor of the commit, not (what I
expected) the closest ancestor after the merge.  I should use git describe
--contains instead.

Ben
