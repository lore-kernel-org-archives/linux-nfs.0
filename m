Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8F8AC282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 11:54:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 90AD32080F
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 11:54:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726334AbfBELyA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 06:54:00 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726276AbfBELyA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 06:54:00 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 91107E6A99;
        Tue,  5 Feb 2019 11:54:00 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id A5B3126E5E;
        Tue,  5 Feb 2019 11:53:59 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Cristian Marussi" <cristian.marussi@arm.com>
Cc:     "Punit Agrawal" <punit.agrawal@arm.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
Date:   Tue, 05 Feb 2019 06:53:58 -0500
Message-ID: <65CE8FC5-3ADB-4E61-8127-70B979B037A0@redhat.com>
In-Reply-To: <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
 <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
 <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 05 Feb 2019 11:54:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello Cristian and Punit,

Did you ever get to the bottom of this one?  We just saw this on one run 
of our 4.18.0-era ppc64le, and I'm wondering if we ever found the root 
cause.

Ben
