Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E44F0C433EF
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Mar 2022 17:40:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232515AbiCIRk7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Mar 2022 12:40:59 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53082 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235406AbiCIRk5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Mar 2022 12:40:57 -0500
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id D2865101F05
        for <linux-nfs@vger.kernel.org>; Wed,  9 Mar 2022 09:39:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1646847597;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=tpHBdQuPxV5pLsk1Lzsj/uAhsmvPHKj8F/UJMnPqaVY=;
        b=Ktm1Y5lg9GH0TWO82cNL4LaPAxgH60dLy5VrdBitZk6mXtNkk6G316eArQs+5Q2gGXNf++
        8X9tPRv7/LdUdwywqxQdwHZNB7UZdyY5yH2o8gQyu856EyCBfOpIAMB6b40feV3uQcxLwB
        Lnlbj10DMBBkISZm5K5OqsxEJ1yhOq8=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-237-9-LNCjZdPaGo5ZpT_HLsqA-1; Wed, 09 Mar 2022 12:39:53 -0500
X-MC-Unique: 9-LNCjZdPaGo5ZpT_HLsqA-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id B3EF9835DE3;
        Wed,  9 Mar 2022 17:39:52 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 6AFEE89288;
        Wed,  9 Mar 2022 17:39:52 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     trondmy@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v9 14/27] NFS: Improve heuristic for readdirplus
Date:   Wed, 09 Mar 2022 12:39:51 -0500
Message-ID: <A7BBBBF2-768E-487C-A890-7E5AF1D40027@redhat.com>
In-Reply-To: <20220227231227.9038-15-trondmy@kernel.org>
References: <20220227231227.9038-1-trondmy@kernel.org>
 <20220227231227.9038-2-trondmy@kernel.org>
 <20220227231227.9038-3-trondmy@kernel.org>
 <20220227231227.9038-4-trondmy@kernel.org>
 <20220227231227.9038-5-trondmy@kernel.org>
 <20220227231227.9038-6-trondmy@kernel.org>
 <20220227231227.9038-7-trondmy@kernel.org>
 <20220227231227.9038-8-trondmy@kernel.org>
 <20220227231227.9038-9-trondmy@kernel.org>
 <20220227231227.9038-10-trondmy@kernel.org>
 <20220227231227.9038-11-trondmy@kernel.org>
 <20220227231227.9038-12-trondmy@kernel.org>
 <20220227231227.9038-13-trondmy@kernel.org>
 <20220227231227.9038-14-trondmy@kernel.org>
 <20220227231227.9038-15-trondmy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 27 Feb 2022, at 18:12, trondmy@kernel.org wrote:

> From: Trond Myklebust <trond.myklebust@hammerspace.com>
>
> The heuristic for readdirplus is designed to try to detect 'ls -l' and
> similar patterns. It does so by looking for cache hit/miss patterns in
> both the attribute cache and in the dcache of the files in a given
> directory, and then sets a flag for the readdirplus code to interpret.
>
> The problem with this approach is that a single attribute or dcache miss
> can cause the NFS code to force a refresh of the attributes for the
> entire set of files contained in the directory.
>
> To be able to make a more nuanced decision, let's sample the number of
> hits and misses in the set of open directory descriptors. That allows us
> to set thresholds at which we start preferring READDIRPLUS over regular
> READDIR, or at which we start to force a re-read of the remaining
> readdir cache using READDIRPLUS.

I like this patch very much.

The heuristic doesn't kick-in until "ls -l" makes its second call into
nfs_readdir(), and for my filenames with 8 chars, that means that there are
about 5800 GETATTRs generated before we clean the cache to do more
READDIRPLUS.  That's a large number to compound on connection latency.

We've already got some complaints that folk's 2nd "ls -l" takes "so much
longer" after 1a34c8c9a49e.

Can we possibly limit our first pass through nfs_readdir() so that the
heuristic takes effect sooner?

Ben

