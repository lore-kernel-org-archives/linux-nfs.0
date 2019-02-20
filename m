Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7185C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 18:12:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C00922083E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 18:12:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725939AbfBTSMy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 13:12:54 -0500
Received: from mx1.redhat.com ([209.132.183.28]:58390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725815AbfBTSMy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 13:12:54 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0C0CC338856;
        Wed, 20 Feb 2019 18:12:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-52.phx2.redhat.com [10.3.116.52])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 93C121A8F3;
        Wed, 20 Feb 2019 18:12:53 +0000 (UTC)
Subject: Re: [PATCH v2] Remove abuse of ai_canonname
To:     Chuck Lever <chuck.lever@oracle.com>,
        Peter Wagner <tripolar@gmx.at>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20190219155220.17240.31293.stgit@manet.1015granger.net>
 <20190219195729.6d893e98@onion.lan>
 <D9488568-838E-45BE-A58C-435581481B48@oracle.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <b7b773ec-579a-7c9e-583e-d3d1de155ca5@RedHat.com>
Date:   Wed, 20 Feb 2019 13:12:53 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <D9488568-838E-45BE-A58C-435581481B48@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 20 Feb 2019 18:12:54 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 2/19/19 2:40 PM, Chuck Lever wrote:
>> On Feb 19, 2019, at 1:57 PM, Peter Wagner <tripolar@gmx.at> wrote:
>>
>> Looks good to me.
>> I run tested it on musl and in combination with me nfs_freeaddrinfo
>> patch it works.
> Very good. Let's see what Steve's testing shows up, if anything.
I've rolled them up and smoking them now!! :-) I'll let you know... 

steved.
