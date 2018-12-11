Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3CEFC07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 13:21:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 346C42082F
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 13:21:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 346C42082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=esat.kuleuven.be
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726212AbeLKNVB convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 08:21:01 -0500
Received: from rhcavspool01.kulnet.kuleuven.be ([134.58.240.193]:49141 "EHLO
        rhcavspool01.kulnet.kuleuven.be" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726135AbeLKNVB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 08:21:01 -0500
X-Greylist: delayed 531 seconds by postgrey-1.27 at vger.kernel.org; Tue, 11 Dec 2018 08:20:58 EST
Received: from rhcavuit04.kulnet.kuleuven.be (rhcavuit04.kulnet.kuleuven.be [134.58.240.137])
        by rhcavspool01.kulnet.kuleuven.be (Postfix) with ESMTP id 50F6914BEA0
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 14:12:07 +0100 (CET)
X-KULeuven-Envelope-From: rik.theys@esat.kuleuven.be
X-KULeuven-Scanned: Found to be clean
X-KULeuven-ID: 8D82D120397.A52B1
X-KULeuven-Information: Katholieke Universiteit Leuven
Received: from icts-p-smtps-2.cc.kuleuven.be (icts-p-smtps-2e.kulnet.kuleuven.be [134.58.240.34])
        by rhcavuit04.kulnet.kuleuven.be (Postfix) with ESMTP id 8D82D120397
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 14:11:59 +0100 (CET)
Received: from hydrogen.esat.kuleuven.be (hydrogen.esat.kuleuven.be [134.58.56.153])
        by icts-p-smtps-2.cc.kuleuven.be (Postfix) with ESMTP id 7BEEA200A6
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 14:11:59 +0100 (CET)
Received: from lucifer.esat.kuleuven.be (lucifer.esat.kuleuven.be [10.87.19.1])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by hydrogen.esat.kuleuven.be (Postfix) with ESMTPSA id 7808E2002C
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 14:11:59 +0100 (CET)
X-Kuleuven: This mail passed the K.U.Leuven mailcluster
From:   Rik Theys <Rik.Theys@esat.kuleuven.be>
Subject: status of NFS4 acls and umask
Openpgp: preference=signencrypt
Autocrypt: addr=Rik.Theys@esat.kuleuven.be; prefer-encrypt=mutual; keydata=
 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
 dBzpT9CJ
Organization: KU Leuven - ESAT
To:     linux-nfs@vger.kernel.org
Message-ID: <0dd5344e-231f-1670-ffe1-5974b57dbaf3@esat.kuleuven.be>
Date:   Tue, 11 Dec 2018 14:11:59 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

In https://www.spinics.net/lists/linux-nfs/msg27799.html from 2011, Jeff
Layton describes how/why an NFSv4 ACL does not override the umask like a
posix ACL does. It mentions that it did not work back then and that
something might be done about that.

What is the status now? When I look at the CentOS 7.6 client/server it
seems this is still not implemented. Is this fixed in newer upstream
versions? If not, are there any plans on finding a solution?

Regards,

Rik

-- 
Rik Theys
System Engineer
KU Leuven - Dept. Elektrotechniek (ESAT)
Kasteelpark Arenberg 10 bus 2440  - B-3001 Leuven-Heverlee
+32(0)16/32.11.07
----------------------------------------------------------------
<<Any errors in spelling, tact or fact are transmission errors>>


