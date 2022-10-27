Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F599ECAAA1
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Oct 2022 13:12:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235778AbiJ0NMh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Oct 2022 09:12:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36900 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236050AbiJ0NME (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2022 09:12:04 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6F8437C1C3
        for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2022 06:11:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1666876291;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=08qQCOq6HXtPu07yJoUG1gykaILDIdfjGgF17Vne+y0=;
        b=ZSXBTSW5Ps2alxXwI9WYzPsg89Mg6UooXJIkTv2NLQCa+zJgawt5oiMLosZlg0+c1YKHMo
        AhiYgRS2FcjoajDw+EvrKRfSJvH24QYatpH5OdnKUVcOz9KmxGhLGEJe5bTYd6ku3+NpJ0
        U9pYqJVXxnTeEmF1l30J47HBsRwjvck=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-649-YAG-GrF1PNKY9HcojBWvQA-1; Thu, 27 Oct 2022 09:11:26 -0400
X-MC-Unique: YAG-GrF1PNKY9HcojBWvQA-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 8D41E811E75;
        Thu, 27 Oct 2022 13:11:25 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.33.36.73])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 66BC01121333;
        Thu, 27 Oct 2022 13:11:24 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <20221027083547.46933-8-jefflexu@linux.alibaba.com>
References: <20221027083547.46933-8-jefflexu@linux.alibaba.com> <20221027083547.46933-1-jefflexu@linux.alibaba.com>
To:     Jingbo Xu <jefflexu@linux.alibaba.com>
Cc:     dhowells@redhat.com, jlayton@kernel.org, linux-cachefs@redhat.com,
        linux-erofs@lists.ozlabs.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 7/9] fscache,netfs: define flags for prepare_read()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3306594.1666876283.1@warthog.procyon.org.uk>
Date:   Thu, 27 Oct 2022 14:11:23 +0100
Message-ID: <3306595.1666876283@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.3
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Jingbo Xu <jefflexu@linux.alibaba.com> wrote:

> +		if (test_bit(FSCACHE_REQ_COPY_TO_CACHE, &flags))
> +			__set_bit(NETFS_SREQ_COPY_TO_CACHE, &subreq->flags);

Please don't do that in netfslib.  Netfslib shouldn't know about fscache's
inner workings.

David

