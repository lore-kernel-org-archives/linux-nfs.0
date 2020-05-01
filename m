Return-Path: <SRS0=2uGU=6P=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A219C47254
	for <linux-nfs@archiver.kernel.org>; Fri,  1 May 2020 04:37:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1BB0A2071C
	for <linux-nfs@archiver.kernel.org>; Fri,  1 May 2020 04:37:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728126AbgEAEhr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 May 2020 00:37:47 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52464 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726153AbgEAEhr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2020 00:37:47 -0400
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk [IPv6:2002:c35c:fd02::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 37521C035494;
        Thu, 30 Apr 2020 21:37:47 -0700 (PDT)
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1jUNQj-00Fc0H-H0; Fri, 01 May 2020 04:37:41 +0000
Date:   Fri, 1 May 2020 05:37:41 +0100
From:   Al Viro <viro@zeniv.linux.org.uk>
To:     Ritesh Harjani <riteshh@linux.ibm.com>
Cc:     linux-fsdevel@vger.kernel.org, willy@infradead.org,
        jlayton@kernel.org, ceph-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        devel@lists.orangefs.org, linux-unionfs@vger.kernel.org,
        dsterba@suse.cz
Subject: Re: [RESEND PATCH 0/1] Use inode_lock/unlock class of provided APIs
 in filesystems
Message-ID: <20200501043741.GK23230@ZenIV.linux.org.uk>
References: <20200101105248.25304-1-riteshh@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200101105248.25304-1-riteshh@linux.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 01, 2020 at 04:22:47PM +0530, Ritesh Harjani wrote:
> Al, any comments?
> Resending this after adding Reviewed-by/Acked-by tags.

.... argh.  My apologies - that got fallen through the cracks.
Could you rebase and resend it?
