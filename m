Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94EE4C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 14:58:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 361A220671
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 14:58:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361A220671
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728034AbeJWXWM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 19:22:12 -0400
Received: from mx1.redhat.com ([209.132.183.28]:51294 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728030AbeJWXWM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Oct 2018 19:22:12 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 136945F780
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 14:58:26 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-66-2.rdu2.redhat.com [10.10.66.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id C0EC074A56
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 14:58:25 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: Archive the list at lore.kernel.org
Date:   Tue, 23 Oct 2018 10:58:28 -0400
Message-ID: <BFE6266E-D3D5-4EDE-9409-B33A61D0E8AE@redhat.com>
In-Reply-To: <400E82D9-5BA9-4542-988A-B2C598F72693@redhat.com>
References: <400E82D9-5BA9-4542-988A-B2C598F72693@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 23 Oct 2018 14:58:26 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Anyone want to help?  Just bumping this during the work week.
I'll wait until Friday.. then send what I have.

Ben

On 21 Oct 2018, at 7:56, Benjamin Coddington wrote:

> Hi, everyone:
>
> I'm working to add this list to lore.kernel.org. As one of 
> prerequisites
> they require that we provide full existing archives of all list 
> messages
> (or, at least, as complete as possible).
>
> Between Scott Mayhew and myself we have a fairly complete collection 
> from
> 2014 until now, but I am sure there are some holes.  For years before 
> that,
> I have a gmane export that I've massaged to clean out as many 
> obfuscated
> gmane addresses as possible, but I can see that gmane has dropped the
> recipient lists for some messages, likely due to a header size limit.
>
> I would really appreciate it if you would pitch in from your own 
> collection
> before I backfill the archive with the gmane messages.
> Just follow the instructions on this page:
> https://korg.wiki.kernel.org/userdoc/lore
>
> Here is a link to the list of message-ids that I already have:
> http://bcodding.com/linux-nfs-known-ids.txt.xz
>
> You'll need it during the archive sanitization process to pass to the 
> -k
> switch.
>
> Please tar up and xz -9 the resulting directory with mbox files and 
> send the
> archive to me so I can add it to what I already have.
>
> Thanks!
> Ben
