Return-Path: <SRS0=qWmq=XI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C75CC49ED7
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Sep 2019 15:37:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3A34120CC7
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Sep 2019 15:37:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730331AbfIMPhv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 13 Sep 2019 11:37:51 -0400
Received: from mx1.redhat.com ([209.132.183.28]:57506 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728811AbfIMPhv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Sep 2019 11:37:51 -0400
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1C7B572FD4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Sep 2019 15:37:51 +0000 (UTC)
Received: by mail-qt1-f197.google.com with SMTP id m20so2512887qtq.16
        for <linux-nfs@vger.kernel.org>; Fri, 13 Sep 2019 08:37:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:reply-to:subject:to:references:from:organization
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=82YeYxk5GMbytwD2V9c7SOqJEDRYtaGZpfNJNExcpek=;
        b=Jq4efss9obxXGdXImDkjpHakQscJFISvIiyh49+I1xWsSpBLOMVg58CtYA3CcJAIc0
         PXdWY8KPC17PWoHr6K/h1W7InGRWl16BUan0gFvEXz/Z7UNJW3wMcreNTiFiCdmjt8+a
         FCC1AFMyTxttMZTlC35DhgLflut2pfCKzWdonh8SouWG+ETpX05OeZpqdBsYHoSDu8Iy
         WTlTmFNtFg3/n+7m7DuGRJUCPEVZtsXibRDg+oXA/njeb1OMOGAIB836Os++ZGZvDae0
         pnZXdfItA2VFXnVbYWSrlCSRGGS86QNfbqT7v4pb20vR8qTZPScdVsZhA/9UMFz3uAB1
         hpyw==
X-Gm-Message-State: APjAAAUNPc43B8mGdBhfO5B5Ve6Ed3JXMJ0bX3lyaU5uhu2wm8wZ/wam
        NgEdJwMC+wKePbpI4e0NkWbysnoOb4dKY8hMaXNbEpSNz++Eu2Kze5ERSsf82H90AX6NXwvLfv7
        cQSsbX3DYrclt8CSIfBDE
X-Received: by 2002:ac8:7089:: with SMTP id y9mr3715094qto.363.1568389070363;
        Fri, 13 Sep 2019 08:37:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxScEZesemOlh2eE1EdYt2c7vEPghTz4dPVP35Jobw0dubJeI8v6FENxNDuepBvdgOvtslxVg==
X-Received: by 2002:ac8:7089:: with SMTP id y9mr3715072qto.363.1568389070193;
        Fri, 13 Sep 2019 08:37:50 -0700 (PDT)
Received: from sidious.arb.redhat.com ([12.118.3.106])
        by smtp.gmail.com with ESMTPSA id q62sm12750158qkb.69.2019.09.13.08.37.49
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 13 Sep 2019 08:37:49 -0700 (PDT)
Reply-To: dang@redhat.com
Subject: Re: support for UDP
To:     Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <CAN-5tyG97C6GTXOz5G6z8SL+jNKYa0siWnSfjijRNVucFs3KwA@mail.gmail.com>
From:   Daniel Gryniewicz <dang@redhat.com>
Organization: Red Hat
Message-ID: <080bf93a-0e66-bb56-a54f-5496c688bb70@redhat.com>
Date:   Fri, 13 Sep 2019 11:37:48 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAN-5tyG97C6GTXOz5G6z8SL+jNKYa0siWnSfjijRNVucFs3KwA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 9/13/19 11:14 AM, Olga Kornievskaia wrote:
> Hi folks,
> 
> I'd like to gauge what people think. Do you think we'd ever do a bold
> thing like drop the UDP support in the upstream kernel (obviously with
> a plan to fade it out with a config option that we did with the des
> support)...
> 

Yes, please.

Daniel
