Return-Path: <SRS0=hurI=TC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8AB7C43219
	for <linux-nfs@archiver.kernel.org>; Thu,  2 May 2019 15:52:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B536820675
	for <linux-nfs@archiver.kernel.org>; Thu,  2 May 2019 15:52:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726336AbfEBPww (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 2 May 2019 11:52:52 -0400
Received: from mx1.redhat.com ([209.132.183.28]:55380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726334AbfEBPww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 May 2019 11:52:52 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B37CC307D983;
        Thu,  2 May 2019 15:52:51 +0000 (UTC)
Received: from [10.10.66.66] (ovpn-66-66.rdu2.redhat.com [10.10.66.66])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id F31305DA5B;
        Thu,  2 May 2019 15:52:50 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Roberto Bergantinos Corpas" <rbergant@redhat.com>
Cc:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Subject: Re: [PATCH] NFS: make nfs_match_client killable
Date:   Thu, 02 May 2019 11:52:49 -0400
Message-ID: <7D6BA417-B507-4359-8168-450690A09E49@redhat.com>
In-Reply-To: <20190425133651.17618-1-rbergant@redhat.com>
References: <20190425133651.17618-1-rbergant@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 02 May 2019 15:52:52 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 25 Apr 2019, at 9:36, Roberto Bergantinos Corpas wrote:

>     Actually we don't do anything with return value from
>     nfs_wait_client_init_complete in nfs_match_client, as a
>     consequence if we get a fatal signal and client is not
>     fully initialised, we'll loop to "again" label
>
>     This has been proven to cause soft lockups on some scenarios
>     (no-carrier but configured network interfaces)
>
> Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>

This looks right to me.

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

Ben
