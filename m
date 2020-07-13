Return-Path: <SRS0=AYid=AY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B547C433E2
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Jul 2020 18:47:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4E6922065D
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Jul 2020 18:47:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="g9ZSkg+i"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726338AbgGMSrh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 13 Jul 2020 14:47:37 -0400
Received: from us-smtp-2.mimecast.com ([207.211.31.81]:28434 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726332AbgGMSrh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2020 14:47:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1594666056;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=/kGa+wbC9ZfeyZcjYhHqMObUkyvbSuIqcoSW9K1YYog=;
        b=g9ZSkg+iB8MoZh2uIjwNnt6xAwnhrFse1XKSZtIRTwe/KpxSVlbIpvzOQG+zaqU/cdqpHa
        sGZeDTVJUbVvEYICULd7lwefrgvIdLSzyuS4JdZqKV22fbwkUWNjdKwGXhDYstW03R9yRp
        uK270oI9rG29c+xRYrlsNiSAd3QF4fY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-237-Us54mDi5Mgy8UL0tzxs3eA-1; Mon, 13 Jul 2020 14:47:32 -0400
X-MC-Unique: Us54mDi5Mgy8UL0tzxs3eA-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id D97931DE0;
        Mon, 13 Jul 2020 18:47:31 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-112-168.phx2.redhat.com [10.3.112.168])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 82E5F60CD0;
        Mon, 13 Jul 2020 18:47:31 +0000 (UTC)
Subject: Re: [PATCH 04/10] gssd: gssd_k5_err_msg() returns a ". Use free() to
 release.
To:     Doug Nazar <nazard@nazar.ca>, linux-nfs@vger.kernel.org
References: <20200701182803.14947-1-nazard@nazar.ca>
 <20200701182803.14947-5-nazard@nazar.ca>
 <3a758b78-e477-4a75-63ca-65333a413599@RedHat.com>
 <cddca53b-54f3-2c4a-f6b4-b0bb2bf2b2f2@nazar.ca>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <ca47067c-3b8f-b33a-a274-87039d5d6cc9@RedHat.com>
Date:   Mon, 13 Jul 2020 14:47:31 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <cddca53b-54f3-2c4a-f6b4-b0bb2bf2b2f2@nazar.ca>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 7/12/20 4:27 PM, Doug Nazar wrote:
> On 2020-07-08 10:50, Steve Dickson wrote:
>> I'm curious about these changes... since all krb5_free_string()
>> does is call free()... where is the "strdup'd msg" coming from?
> 
> gssd_k5_err_msg() always returns a local strdup() of the error message. 
True... 

> We shouldn't be using a Kerberos library method to free them. There's no guarantee that the library won't change, 
I guess I'm not too worry about this... I would the change was for the better.
and lets face the krb5 has not changed in a 100 years ;-) 

> or even that the library was compiled with the same malloc library.
There are different malloc libraries other than glibc? 

steved.

