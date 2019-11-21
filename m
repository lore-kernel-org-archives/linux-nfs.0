Return-Path: <SRS0=HWLc=ZN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 120E8C43141
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Nov 2019 05:52:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E880D20898
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Nov 2019 05:52:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726536AbfKUFwr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Nov 2019 00:52:47 -0500
Received: from namei.org ([65.99.196.166]:41520 "EHLO namei.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726230AbfKUFwr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Nov 2019 00:52:47 -0500
Received: from localhost (localhost [127.0.0.1])
        by namei.org (8.14.4/8.14.4) with ESMTP id xAL5qePx005639;
        Thu, 21 Nov 2019 05:52:40 GMT
Date:   Thu, 21 Nov 2019 16:52:40 +1100 (AEDT)
From:   James Morris <jmorris@namei.org>
To:     Scott Mayhew <smayhew@redhat.com>
cc:     anna.schumaker@netapp.com, trond.myklebust@hammerspace.com,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [PATCH v5 15/27] nfs: get rid of ->set_security()
In-Reply-To: <20191120152750.6880-16-smayhew@redhat.com>
Message-ID: <alpine.LRH.2.21.1911211651220.3625@namei.org>
References: <20191120152750.6880-1-smayhew@redhat.com> <20191120152750.6880-16-smayhew@redhat.com>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 20 Nov 2019, Scott Mayhew wrote:

> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> it's always either nfs_set_sb_security() or nfs_clone_sb_security(),
> the choice being controlled by mount_info->cloned != NULL.  No need
> to add methods, especially when both instances live right next to
> the caller and are never accessed anywhere else.
> 
> Reviewed-by: David Howells <dhowells@redhat.com>
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Please ensure that any changes relating to the LSM API are cc'd to the 
linux-security-module list.


-- 
James Morris
<jmorris@namei.org>

