Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 822E6C4332F
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Sep 2021 14:56:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4FC076103E
	for <linux-nfs@archiver.kernel.org>; Wed, 29 Sep 2021 14:56:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344858AbhI2O62 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 29 Sep 2021 10:58:28 -0400
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:32652 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1344752AbhI2O61 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2021 10:58:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1632927405;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=JWTa7QrPgfGKVGWtPtI90NbmGY06wVpTfT1EeOiXArk=;
        b=MkkKhJrZXxLLXP0ruzuXYwDMf0dfai6XclwZ5ylP+wxtbOt2G4sozDFnfZCW2bl1iWuqv+
        cyBG7bTayflRKuiY43jF2mZ+FBHSI4MYQIEdeq+DRJaVM6VYV5fRr6C4esjRqlcRXcNtBX
        0ImP1sayuEQHTGLsVmsZ5kkP/tl56Og=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-259-IYxMmSs6M1mIvC0h985jGQ-1; Wed, 29 Sep 2021 10:56:43 -0400
X-MC-Unique: IYxMmSs6M1mIvC0h985jGQ-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 3389918125C2;
        Wed, 29 Sep 2021 14:56:42 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id DB666102488A;
        Wed, 29 Sep 2021 14:56:41 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     trondmy@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] NFS: Further optimisations for 'ls -l'
Date:   Wed, 29 Sep 2021 10:56:40 -0400
Message-ID: <C9ED123C-A092-4417-8597-AB6267379E2F@redhat.com>
In-Reply-To: <20210929134944.632844-4-trondmy@kernel.org>
References: <20210929134944.632844-1-trondmy@kernel.org>
 <20210929134944.632844-2-trondmy@kernel.org>
 <20210929134944.632844-3-trondmy@kernel.org>
 <20210929134944.632844-4-trondmy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 29 Sep 2021, at 9:49, trondmy@kernel.org wrote:

> From: Trond Myklebust <trond.myklebust@hammerspace.com>
>
> If a user is doing 'ls -l', we have a heuristic in GETATTR that tells
> the readdir code to try to use READDIRPLUS in order to refresh the inode
> attributes. In certain cirumstances, we also try to invalidate the
> remaining directory entries in order to ensure this refresh.
>
> If there are multiple readers of the directory, we probably should avoid
> invalidating the page cache, since the heuristic breaks down in that
> situation anyway.

Hi Trond, I'm curious about the motivation for this work because we're often
managing expectations about performance between various workloads.  What
does the workload look like that prompted you to make this optimization?

I'm also interested because I have some work that improves readdir
performance for multiple readers on large directories, but is rotting
because things have been "good enough" for folks over here.

Ben

