Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAE2EC10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 22:36:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9466C222D9
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 22:36:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391539AbfBOWgV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 17:36:21 -0500
Received: from namei.org ([65.99.196.166]:52504 "EHLO namei.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2390411AbfBOWgU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 17:36:20 -0500
Received: from localhost (localhost [127.0.0.1])
        by namei.org (8.14.4/8.14.4) with ESMTP id x1FMa4QR006885;
        Fri, 15 Feb 2019 22:36:04 GMT
Date:   Sat, 16 Feb 2019 09:36:04 +1100 (AEDT)
From:   James Morris <jmorris@namei.org>
To:     David Howells <dhowells@redhat.com>
cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org, ebiederm@xmission.com
Subject: Re: [RFC PATCH 00/27] Containers and using authenticated
 filesystems
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
Message-ID: <alpine.LRH.2.21.1902160934140.6353@namei.org>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 15 Feb 2019, David Howells wrote:

> 
> Here's a collection of patches that containerises the kernel keys and makes
> it possible to separate keys by namespace.  This can be extended to any
> filesystem that uses request_key() to obtain the pertinent authentication
> token on entry to VFS or socket methods.

Shouldn't Eric Biederman be cc'd on this?

-- 
James Morris
<jmorris@namei.org>

