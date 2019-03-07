Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2593CC43381
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 11:12:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E4DDD20675
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 11:12:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726101AbfCGLMz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 06:12:55 -0500
Received: from mx1.redhat.com ([209.132.183.28]:46894 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726028AbfCGLMz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Mar 2019 06:12:55 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E657A307D97F;
        Thu,  7 Mar 2019 11:12:54 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-66.rdu2.redhat.com [10.10.112.66])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 364C06013F;
        Thu,  7 Mar 2019 11:12:54 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     Kanika <jr.kanika@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: pnfs setup on Linux 4.15
Date:   Thu, 07 Mar 2019 06:12:52 -0500
Message-ID: <C235C237-B75C-4EED-B2F1-1F5E084B21CD@redhat.com>
In-Reply-To: <CAP8UQm+j4Rog_AK8yiOwTY_3pBbV3OwKU7KvoU2B064hmC9gWA@mail.gmail.com>
References: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
 <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com>
 <A469AE7A-B542-4BE7-BF1E-5EFD309DB0BB@redhat.com>
 <CAP8UQm+j4Rog_AK8yiOwTY_3pBbV3OwKU7KvoU2B064hmC9gWA@mail.gmail.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 07 Mar 2019 11:12:54 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 7 Mar 2019, at 2:51, Kanika wrote:

> Hi Benjamin,
> Thanks for your reply. I suspected so but wanted to confirm. I tried
> block/scsi layout as well but that isn't working either.
>
> Based on an old thread on this list on "how to setup pnfs for block
> layout", I set up an iscsi target on the DS and the initiators on the MDS
> and client. All machines are running 4.15 kernel. Client as an iscsi
> initiator but does not mount the device. MDS also an initiator with an xfs
> filesystem mounted on the device. This mount point is exported as an nfs
> share from the MDS. The client mounts the exported MDS share.
> By default LAYOUT_SCSI is used but the GETDEVICEINFO call keeps failing
> with NFS4ERR_INVAL. As a result all reads/writes from the client are routed
> to the MDS instead of the DS. Anything wrong with my setup?

The SCSI layout needs to work with whole SCSI devices, not partitions.

Try putting your XFS on /dev/sda instead of /dev/sda1.

Ben
