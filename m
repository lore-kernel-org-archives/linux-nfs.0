Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0964C32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 21:03:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D5532083D
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 21:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D5532083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=candelatech.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388401AbeKGGbE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 01:31:04 -0500
Received: from mail2.candelatech.com ([208.74.158.173]:44258 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727297AbeKGGbE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Nov 2018 01:31:04 -0500
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 3D9F540A79A
        for <linux-nfs@vger.kernel.org>; Tue,  6 Nov 2018 13:03:55 -0800 (PST)
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From:   Ben Greear <greearb@candelatech.com>
Subject: Support for VRF in NFS?
Organization: Candela Technologies
Message-ID: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
Date:   Tue, 6 Nov 2018 13:03:54 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

I made a stab at implementing VRF support in NFS, but it appears
fairly complicated and I ended up reverting my changes....

Is anyone working on this?

And, if not, if anyone would like to be sponsored to work on this, please
let me know.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

