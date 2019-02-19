Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E279C4360F
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:06:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EFEEE21738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:06:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728290AbfBSXGU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:06:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:58760 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726402AbfBSXGU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 18:06:20 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4462856FC;
        Tue, 19 Feb 2019 23:06:20 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D93D3600C0;
        Tue, 19 Feb 2019 23:06:14 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <1550432358.2809.21.camel@HansenPartnership.com>
References: <1550432358.2809.21.camel@HansenPartnership.com> <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk> <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
To:     James Bottomley <James.Bottomley@HansenPartnership.com>
Cc:     dhowells@redhat.com, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <19561.1550617574.1@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 23:06:14 +0000
Message-ID: <19562.1550617574@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 19 Feb 2019 23:06:20 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> I thought we got agreement years ago that containers don't exist in
> Linux as a single entity: they're currently a collection of cgroups and
> namespaces some of which may and some of which may not be local to the
> entity the orchestration system thinks of as a "container".

I wasn't party to that agreement and don't feel particularly bound by it.

David
