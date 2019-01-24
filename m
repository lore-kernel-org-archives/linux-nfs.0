Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCCCCC282C5
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 19:17:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A99C1218CD
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 19:17:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ngCu9brs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727488AbfAXTRy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 14:17:54 -0500
Received: from mail-pl1-f196.google.com ([209.85.214.196]:43475 "EHLO
        mail-pl1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727898AbfAXTRv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2019 14:17:51 -0500
Received: by mail-pl1-f196.google.com with SMTP id gn14so3314760plb.10
        for <linux-nfs@vger.kernel.org>; Thu, 24 Jan 2019 11:17:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=hdv1i0pvseCepLH6vzEQIOAL68CGq/3YNhRfHjBOkmE=;
        b=ngCu9brsjrJ89J44lOM22Th90+2fkjEk5gnPsHAc0Or3P0RgYaecPkMJjfQzCIQKZF
         J6tEUeMErW3rcXT9AiWCVy0RpRcUGAVxx0FfDdm/OJWzoZ6CfaO5yn9AwJZBF43CjH5q
         XkUxEYYv/DoMsVef4CLluweubIBf/LEzMa0SPPwCHCxbtU91d6ssEKySZsEotA7/ZPAl
         fl/2rS5fiU0Q8SqkFPd0c4eztz8Beub+gVZ47re3SzgILqNojsmEtqmlglTAG4WV/8gP
         E4taAVrvAybfBCDkkbxATG/S4rSoSwEr8rJuGiRjuqYzY4C6sY6LrfL3hJCPYX+bvaLH
         bLIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=hdv1i0pvseCepLH6vzEQIOAL68CGq/3YNhRfHjBOkmE=;
        b=dJInuVG8CtEKrpHsPHrmhNTRDxzHBuQlLqYUl0oDjFNdi4SyVymqgzZSDACoynGbHq
         uvw8hqHmIWKioMXDk5E3NrStTqlhDhgRWt0vk/Kdh1I1xyIA+n6EoXHrLCjXGgCoAmpV
         ccef4XS9vGEZDvAcTZhgLp4hfTu+TVFB9x1KRcR4vqv2LB/Z4BTgTpq7nkgCR3AoRS6E
         U4H7PfJ3MVwpiwNeUt8SeM0+bgY2IXP8v8jp6A0O8j76J3PoVuwcL4AJd88nI4H4/Jtu
         EUNzAYwdIr4xikmtyV/SdSMm9jtzEoJSzlwdh+9cv8gw7K5I+XPL9woLSfvd1mvJqCPf
         NKeA==
X-Gm-Message-State: AJcUukcyffOBWk5Y6X3H3UovjkwHsQK7dMV8afccJ+cT29pkCo+m9lVL
        +MHjZ5S3UMccBdi2IIxwg5I=
X-Google-Smtp-Source: ALg8bN6R0NqMPBEFDiEBSIWXiUV7hyNOoACbR2j5sWkSSvJis9eonNUqzYedZf4kyp9738bpcAQsUQ==
X-Received: by 2002:a17:902:e18c:: with SMTP id cd12mr7347023plb.279.1548357470863;
        Thu, 24 Jan 2019 11:17:50 -0800 (PST)
Received: from [10.3.0.116] ([8.25.222.2])
        by smtp.gmail.com with ESMTPSA id z14sm26556019pgv.47.2019.01.24.11.17.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 11:17:50 -0800 (PST)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] lockd: NSMPROC_MON should be send only once even if in
 multithread
From:   Chuck Lever <chucklever@gmail.com>
In-Reply-To: <bdef1ea6-1b71-a638-7274-d2109db5e1d1@huawei.com>
Date:   Thu, 24 Jan 2019 11:17:48 -0800
Cc:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <DE9790AD-A95E-43CB-9A5C-A55DD10294CC@gmail.com>
References: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
 <4E812155-4DB4-4EF4-91ED-EDBB1B0BBFF7@gmail.com>
 <00390d85-d2dd-be57-4192-bff562a75684@huawei.com>
 <E87ADB64-FE89-48A8-A401-3153E029D0DA@gmail.com>
 <bdef1ea6-1b71-a638-7274-d2109db5e1d1@huawei.com>
To:     "zhangxiaoxu (A)" <zhangxiaoxu5@huawei.com>
X-Mailer: Apple Mail (2.3445.9.1)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 24, 2019, at 4:29 AM, zhangxiaoxu (A) <zhangxiaoxu5@huawei.com> =
wrote:
>=20
>=20
>=20
> On 1/19/2019 4:59 AM, Chuck Lever wrote:
>>> On Jan 17, 2019, at 9:48 PM, zhangxiaoxu (A) =
<zhangxiaoxu5@huawei.com> wrote:
>>>=20
>>>=20
>>>=20
>>> On 1/17/2019 10:33 PM, Chuck Lever wrote:
>>>> Hi, what is the harm of sending more than one MON request for a =
peer?
>>> Maybe no harm.
>>> The rpc.statd won't record the peer twice.
>>>=20
>>> I found this when I tested the xfstest generic/089.
>>> The rpc task for that msg sometimes take very long time.
>>> rpc took 57 sec who t_mtab/2377 srv rpc.statd xid 2453489031 prog =
statd/100024/1 proc 2 prot 6 flags 0x680
>> MON is supposed to be a call to a local service (on the same host).
>> It would be interesting if you could determine why it takes so long.
> Yes, I'm working for that.
> I think this is an optimization point.
> Why do we have to send multiple requests?

I agree that multiple requests are unnecessary, but
they are harmless too. I don't think it's worth the
trouble to change this behavior.

The problem is MON requests on your system takes too long.


>>> I think the msg just send only one time is enough.
>>> RPC and rpc.statd maybe consume for a long time on the network.
>> --
>> Chuck Lever
>> chucklever@gmail.com

--
Chuck Lever
chucklever@gmail.com



