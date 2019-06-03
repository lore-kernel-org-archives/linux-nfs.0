Return-Path: <SRS0=2G4p=UC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EB18C04AB5
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Jun 2019 15:13:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E675E2407D
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Jun 2019 15:13:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="aX0/t5GL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729038AbfFCPNw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Jun 2019 11:13:52 -0400
Received: from smtp-o-3.desy.de ([131.169.56.156]:39491 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729011AbfFCPNv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jun 2019 11:13:51 -0400
X-Greylist: delayed 382 seconds by postgrey-1.27 at vger.kernel.org; Mon, 03 Jun 2019 11:13:51 EDT
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [IPv6:2001:638:700:1038::1:a6])
        by smtp-o-3.desy.de (Postfix) with ESMTP id 834C8601FE
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jun 2019 17:07:28 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 834C8601FE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1559574448; bh=/OnVyqXrC1O/FPVWtMOQhejKB9OczroYQvFDsdCPNkg=;
        h=Date:From:To:Subject:From;
        b=aX0/t5GLpy8opi89ChDyO5eulOTN9KCDIOH1rCEqmGu6jXiycXFbU+ZvlHHXC63+K
         fJZ3InOFqoj4MJ7XjZSH8a+1l8cVuvsU2wpoU70r1ra9RpfSEUcUYgENx/8/84GJQM
         jKKbBVkyPf8RscDhk1FJ+VowXsL8DixY75DwE5jk=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [131.169.56.131])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 7E965A0077
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jun 2019 17:07:28 +0200 (CEST)
X-Virus-Scanned: amavisd-new at desy.de
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-1.desy.de (Postfix) with ESMTP id 5CC65C003B
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jun 2019 17:07:28 +0200 (CEST)
Date:   Mon, 3 Jun 2019 17:07:28 +0200 (CEST)
From:   "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To:     linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1811809323.9701664.1559574448351.JavaMail.zimbra@desy.de>
Subject: NFS (pNFS) and VM dirty bytes
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 8.8.10_GA_3781 (ZimbraWebClient - FF67 (Linux)/8.8.10_GA_3786)
Thread-Index: cmnjngump0CQm9y9bsnEoMSaFt7C8Q==
Thread-Topic: NFS (pNFS) and VM dirty bytes
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



Dear NFS fellows,

though this is not directly NFS issue, I post this question
here as we mostly affected by NFS clients (and you have enough
kernel connection to route it to the right people).

We have 25 new data processing nodes with 32 cores, 256 GB RAM and 25 Gb/s NIC.
They run CentOS 7 (but this is irrelevant, I think).

When each node runs 24 parallel write incentive (75% write, 25% read) workloads, we see a spike of
IO errors on close. Client runs into timeout due to slow network or IO starvation on the NFS servers.
It stumbles, disconnects, establishes a new connection and stumbled again...

As default values for dirty pages is

vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_ratio = 30

the first data get sent when at least 25GB of data is accumulated.

To get the full deployment more responsive, we have reduced default numbers to something more reasonable:

vm.dirty_background_ratio = 0
vm.dirty_ratio = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 536870912

IOW, we force client to start to send data as soon as 64MB is written. The question is how get this
values optimal and how make them file system/mount point specific.

Thanks in advance,
   Tigran.

