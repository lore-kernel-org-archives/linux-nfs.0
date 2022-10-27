Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 912AFFA3740
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Oct 2022 13:09:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235453AbiJ0NJf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Oct 2022 09:09:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35120 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235974AbiJ0NJ3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2022 09:09:29 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 40FB6C51
        for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2022 06:09:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1666876165;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=zAaHAd6Stt887euCzmeFj9gNHsGngNEgRN3GcxeQNb8=;
        b=UimT4SvsYxsDUBWwlOCpyyjbKnxA77QkB0VRQ1JTUhkwffHSVaZD9j/GaSOWSIo248nzr8
        e05ejZWDvmoQCTtTtKV1QKBEZbLg51Ih3ewTC91MKG/J68K1mCs7zNSVQhnCNew21ocG8V
        9dnNsKkTBuX/dwdBb865oC6JKwfZmHM=
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-159-YWNKULRXP3KrVVVoXhw6_Q-1; Thu, 27 Oct 2022 09:09:23 -0400
X-MC-Unique: YWNKULRXP3KrVVVoXhw6_Q-1
Received: from smtp.corp.redhat.com (int-mx10.intmail.prod.int.rdu2.redhat.com [10.11.54.10])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 4DDBA296A60E;
        Thu, 27 Oct 2022 13:09:23 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.33.36.73])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 296CA492B07;
        Thu, 27 Oct 2022 13:09:22 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <20221027083547.46933-5-jefflexu@linux.alibaba.com>
References: <20221027083547.46933-5-jefflexu@linux.alibaba.com> <20221027083547.46933-1-jefflexu@linux.alibaba.com>
To:     Jingbo Xu <jefflexu@linux.alibaba.com>
Cc:     dhowells@redhat.com, jlayton@kernel.org, linux-cachefs@redhat.com,
        linux-erofs@lists.ozlabs.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/9] fscache,netfs: rename netfs_read_from_hole as fscache_read_from_hole
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3306472.1666876161.1@warthog.procyon.org.uk>
Date:   Thu, 27 Oct 2022 14:09:21 +0100
Message-ID: <3306473.1666876161@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.10
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Jingbo Xu <jefflexu@linux.alibaba.com> wrote:

> Rename netfs_read_from_hole as fscache_read_from_hole to make raw
> fscache APIs more neutral independent on libnetfs.

Please don't.  This is a netfslib feature that's used by fscache.

David

