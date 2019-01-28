Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D39D5C282C8
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 18:55:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB9382171F
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 18:55:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726694AbfA1Szi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jan 2019 13:55:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726678AbfA1Szi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jan 2019 13:55:38 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E5566C05D41C;
        Mon, 28 Jan 2019 18:55:37 +0000 (UTC)
Received: from [10.10.121.184] (ovpn-121-184.rdu2.redhat.com [10.10.121.184])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 31CD219481;
        Mon, 28 Jan 2019 18:55:36 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Always return the error that truncates a flushing
 page
Date:   Mon, 28 Jan 2019 13:55:34 -0500
Message-ID: <4512E750-0B6F-4842-B7B8-469FF04FBB00@redhat.com>
In-Reply-To: <9fc3d4ee7d8eafdfdb7b7c1397ecb25dd22e12b7.camel@hammerspace.com>
References: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
 <9fc3d4ee7d8eafdfdb7b7c1397ecb25dd22e12b7.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 28 Jan 2019 18:55:37 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 28 Jan 2019, at 12:59, Trond Myklebust wrote:
> Hi Ben
>
> We were apparently both looking at the same code last week ☺. I have a
> similar patch, but that also fixes a similar clobbering issue with the
> nfs_error_is_fatal() error just a few lines further down.
>
> Without the extra hunk, we could end up converting an interrupted call
> into a 'successful' write.
>
> Cheers
>   Trond

Looks right to me.  I hope you'll take the Fixes and stable version from
my patch, which will cover the problem I'm seeing.

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

Ben
