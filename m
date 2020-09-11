Return-Path: <SRS0=Q540=CU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EF13C433E2
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Sep 2020 12:11:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D14A621D40
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Sep 2020 12:11:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725811AbgIKMLl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Sep 2020 08:11:41 -0400
Received: from cerberus.halldom.com ([79.135.97.241]:50427 "EHLO
        cerberus.halldom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725822AbgIKMLB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2020 08:11:01 -0400
X-Greylist: delayed 1500 seconds by postgrey-1.27 at vger.kernel.org; Fri, 11 Sep 2020 08:11:01 EDT
Received: from ceres.halldom.com ([79.135.97.244]:61596)
        by cerberus.halldom.com with esmtpsa  (TLS1.3) tls TLS_AES_128_GCM_SHA256
        (Exim 4.94)
        (envelope-from <linux-nfs@gmch.uk>)
        id 1kGhV8-000GVI-Ut
        for linux-nfs@vger.kernel.org; Fri, 11 Sep 2020 12:45:58 +0100
Subject: mount.nfs4 and logging
To:     linux-nfs@vger.kernel.org
References: <S1725851AbgIKKt5/20200911104957Z+185@vger.kernel.org>
From:   Chris Hall <linux-nfs@gmch.uk>
Message-ID: <a38a1249-c570-9069-a498-5e17d85a418a@gmch.uk>
Date:   Fri, 11 Sep 2020 12:45:58 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:68.0) Gecko/20100101
 Thunderbird/68.12.0
MIME-Version: 1.0
In-Reply-To: <S1725851AbgIKKt5/20200911104957Z+185@vger.kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


I have a client and server configured for nfs4 only.

The configuration used to work.

I have just upgraded from Fedora 31 to 32 on the client.  I now get:

   # mount /foo
   mount.nfs4: Protocol not supported

Wireshark does not detect any attempt by the client to talk to the server.

I get the same result if I do mount.nfs4 directly.

Can I wind up the logging for mount.nfs4 ?  Or otherwise find a way to 
discover why the "Protocol not supported" message is being issued ?

Thanks,

Chris
