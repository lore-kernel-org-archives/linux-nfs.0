Return-Path: <SRS0=zz3K=3G=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B267C33CB1
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jan 2020 12:54:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 53B7B2082F
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jan 2020 12:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iiq3cZzp"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726950AbgAQMyp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 Jan 2020 07:54:45 -0500
Received: from us-smtp-1.mimecast.com ([205.139.110.61]:55812 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726329AbgAQMym (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2020 07:54:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1579265681;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=AFfs4BHEVtIdGP7ZwEtFXmYekxAUED+R6+Hy25vvWes=;
        b=iiq3cZzpnKbeVaRhv5OmQe52imAMrDGsxJCY64VHF+sRCnpx/aTIwifjNtTb54kL2dZtV9
        gk/bHxMWC2askJZ++yWstlOWg5De7bcwQ1PI2VDl1XcGbEBNxWqGaZ20as8x1KFWXu87Ib
        FJq3kRf+ST4kCGUFIB2ytg701Qe8jCw=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-112-I5PdBffjOaWrWO_JuMIH9w-1; Fri, 17 Jan 2020 07:54:38 -0500
X-MC-Unique: I5PdBffjOaWrWO_JuMIH9w-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id CBEBE107ACCC;
        Fri, 17 Jan 2020 12:54:36 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-120-49.rdu2.redhat.com [10.10.120.49])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0B4AF5C3F8;
        Fri, 17 Jan 2020 12:54:34 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <CAJKOXPeCVwZfBsCVbc9RQUGi0UfWQw0uFamPiQasiO8fSthFsQ@mail.gmail.com>
References: <CAJKOXPeCVwZfBsCVbc9RQUGi0UfWQw0uFamPiQasiO8fSthFsQ@mail.gmail.com>
To:     Krzysztof Kozlowski <krzk@kernel.org>
Cc:     dhowells@redhat.com,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Scott Mayhew <smayhew@redhat.com>,
        Arnd Bergmann <arnd@arndb.de>
Subject: Re: [BISECT BUG] NFS v4 root not working after 6d972518b821 ("NFS: Add fs_context support.")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <365389.1579265674.1@warthog.procyon.org.uk>
Date:   Fri, 17 Jan 2020 12:54:34 +0000
Message-ID: <365390.1579265674@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Which git tree/branch are you using?

David

