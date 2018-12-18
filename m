Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C6E8C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 21:31:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 75BF821871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 21:31:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726716AbeLRVbi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 16:31:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726675AbeLRVbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 16:31:38 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6620BD4001
        for <linux-nfs@vger.kernel.org>; Tue, 18 Dec 2018 21:31:38 +0000 (UTC)
Received: from rules.brq.redhat.com (ovpn-112-21.sin2.redhat.com [10.67.112.21])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3D41467CFD
        for <linux-nfs@vger.kernel.org>; Tue, 18 Dec 2018 21:31:36 +0000 (UTC)
From:   Vladis Dronov <vdronov@redhat.com>
To:     "linux-nfs @ vger . kernel . org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Date:   Tue, 18 Dec 2018 22:31:34 +0100
Message-Id: <20181218213134.2363-1-vdronov@redhat.com>
In-Reply-To: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 18 Dec 2018 21:31:38 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

The CVE-2018-16884 id was assigned to this flaw and proposed to MITRE.
We would like to suggest to use this id in public communications
regarding this flaw.

Best regards,
Vladis Dronov | Red Hat, Inc. | Product Security Engineer
