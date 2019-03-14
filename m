Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E2C9C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 07:51:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 646472087C
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 07:51:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726606AbfCNHvM convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 03:51:12 -0400
Received: from mail.lysator.liu.se ([130.236.254.3]:44597 "EHLO
        mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726530AbfCNHvM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Mar 2019 03:51:12 -0400
Received: from mail.lysator.liu.se (localhost [127.0.0.1])
        by mail.lysator.liu.se (Postfix) with ESMTP id DF6D440003
        for <linux-nfs@vger.kernel.org>; Thu, 14 Mar 2019 08:51:09 +0100 (CET)
Received: from [IPv6:2001:6b0:17:f002:7dd3:9167:31e9:fb48] (unknown [IPv6:2001:6b0:17:f002:7dd3:9167:31e9:fb48])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.lysator.liu.se (Postfix) with ESMTPSA id CAAE340002
        for <linux-nfs@vger.kernel.org>; Thu, 14 Mar 2019 08:51:09 +0100 (CET)
From:   Peter Eriksson <pen@lysator.liu.se>
Content-Type: text/plain;
        charset=utf-8
Content-Transfer-Encoding: 8BIT
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [Patch] NULL-pointer dereference in gssd (nfs-utils version
 1.3.0, 1.3.4 & 2.3.3)
Date:   Thu, 14 Mar 2019 08:51:08 +0100
References: <77C72E28-D137-408E-834B-623341F21BB3@lysator.liu.se>
 <0B89AD32-CDD9-4AD4-A059-DDB3580E172D@lysator.liu.se>
 <74c72830-0702-0927-dc5a-f3d99019498a@RedHat.com>
To:     linux-nfs@vger.kernel.org
In-Reply-To: <74c72830-0702-0927-dc5a-f3d99019498a@RedHat.com>
Message-Id: <9DFD764A-4D2F-4E65-87C8-1CCA29056702@lysator.liu.se>
X-Mailer: Apple Mail (2.3445.102.3)
X-Virus-Scanned: ClamAV using ClamSMTP
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On 11 Mar 2019, at 19:25, Steve Dickson <SteveD@RedHat.com> wrote:
> 
> Hello Peter,
> ...
> Secondly, patches that fix a fields that are NULL but not knowing
> why they are NULL... most likely is covering over the real bug.
> 
> Any idea why  clp->protocol is sometimes NULL?

I’ve been trying to figure that one out, but since it typically only happens after a couple of hours of continuous testing I’ve yet to find the culprit.

This patch at least makes the rpc.gssd daemon stop crashing - which when that happens will make all further NFS (with sec=krb5) client stuff fail miserably (not good if that happens on a user login server…)

I’ve resent the patch according to your instructions now.

- Peter


