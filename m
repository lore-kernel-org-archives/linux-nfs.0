Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB3D4C4167D
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Nov 2023 14:50:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229498AbjKAOuN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Nov 2023 10:50:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46510 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229800AbjKAOuM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Nov 2023 10:50:12 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 36ECBED
        for <linux-nfs@vger.kernel.org>; Wed,  1 Nov 2023 07:49:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1698850162;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=fpOYd6JuMh7v1XUh4Ug+MNkt5PJsPlFld80C9sZrBz4=;
        b=NqgZXeN9ULv3Gm0gdcXRPAkIdC/uNoCDH8DMyLxDwakVg9KOXSmLTJofrKliy1WD3/cVU7
        CXMx6bFdrbuuJJULJaus/kvyCVd61dgSJwVYppHhVIAZdn0Gc9eNZXC4k8OSCjqodu3LT+
        6NuF+g8OG1WUxefN5rvkHrXi+hNm5LA=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-594-1GbmYFxaNa--cnaTr2xnGw-1; Wed, 01 Nov 2023 10:49:19 -0400
X-MC-Unique: 1GbmYFxaNa--cnaTr2xnGw-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 9F2ED833962;
        Wed,  1 Nov 2023 14:49:18 +0000 (UTC)
Received: from [192.168.37.1] (unknown [10.22.50.5])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 3222410F52;
        Wed,  1 Nov 2023 14:49:18 +0000 (UTC)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     Martin Wege <martin.l.wege@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Linux NFSv4 client maintainer?
Date:   Wed, 01 Nov 2023 10:49:16 -0400
Message-ID: <45F5C27D-4D6A-4879-9A69-C38C70896DD1@redhat.com>
In-Reply-To: <CANH4o6MYtA60MJ6=4Gg3ApzpZ42TzQiD13g1EE9OXkyM+8_Ssg@mail.gmail.com>
References: <CANH4o6MYtA60MJ6=4Gg3ApzpZ42TzQiD13g1EE9OXkyM+8_Ssg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.5
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 1 Nov 2023, at 5:40, Martin Wege wrote:

> Good morning!
>
> Who is the NFSv4 client maintainer these days?

Linux kernel maintainers are listed in MAINTAINERS.  You can use
./scripts/get_maintainer.pl to lookup maintainers by path:

$ ./scripts/get_maintainer.pl  -f fs/nfs/super.c
trond.myklebust@hammerspace.com,anna@kernel.org

Documentation/process/howto.rst is a nice light read that would have
answered this question for you.

Ben

