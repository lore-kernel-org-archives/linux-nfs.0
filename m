Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48EE3C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 07:53:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 16FB520672
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 07:53:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16FB520672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725842AbeLCHxM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 02:53:12 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33616 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725832AbeLCHxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 02:53:12 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F3C8183F4C
        for <linux-nfs@vger.kernel.org>; Mon,  3 Dec 2018 07:53:07 +0000 (UTC)
Received: from localhost.localdomain (ovpn-112-31.sin2.redhat.com [10.67.112.31])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7AB385D778;
        Mon,  3 Dec 2018 07:53:01 +0000 (UTC)
From:   Soumya Koduri <skoduri@redhat.com>
Subject: NFS client behavior on WRITE_DELEGATION
To:     linux-nfs@vger.kernel.org
Cc:     Matt Benjamin <mbenjamin@redhat.com>
Message-ID: <68c7c07a-949d-1ce0-ec7e-5ab71ffaaa3b@redhat.com>
Date:   Mon, 3 Dec 2018 13:22:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 03 Dec 2018 07:53:08 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

In our NFSv4.1 Delegations testing we observed that NFS client sends 
WRITE requests to the server even when granted WRITE_DELEGATION. I see 
that only OPEN/CLOSE and LOCK operations are served locally by the client.

Please confirm if this behavior is expected and if yes, can it be 
improved to avoid sending WRITEs to the server until the application 
does fsync.

Thanks,
Soumya
