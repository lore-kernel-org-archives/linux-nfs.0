Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:55032 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932360AbeFOOLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Jun 2018 10:11:00 -0400
MIME-Version: 1.0
In-Reply-To: <CAJKOXPfX0CytKcYDaDAYYuCQjk-mcGjFRHfZco-wPQsc4G1agA@mail.gmail.com>
References: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
 <CAPKp9uZ79ybkv7dMpcy2GQ9L+rWk+vdExQ48diWWQPOUdDQtSQ@mail.gmail.com> <CAJKOXPfX0CytKcYDaDAYYuCQjk-mcGjFRHfZco-wPQsc4G1agA@mail.gmail.com>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Fri, 15 Jun 2018 16:10:58 +0200
Message-ID: <CAJKOXPcmV7qvSuNwcQNDrwQSg3=674Gw_kNfkPHac_Vh9JcWVw@mail.gmail.com>
Subject: Re: [BUG BISECT] NFSv4 client fails on Flush Journal to Persistent Storage
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 15, 2018 at 4:07 PM, Krzysztof Kozlowski <krzk@kernel.org> wrote:
>
> I test it on systemd versions 236 and 238... and it fails on both.
> However one board passes always - it is Odroid HC1 with same core
> configuration as described before. Probably there is some different SW
> package on it.
>
>>> Let me know if you need any more information.
>>>
>>
>> Also I was observing this issue with Linus master branch from
>> the time the above patch was merged until today. The issue
>> is no longer seen since this morning however I just enabled lockdep
>> and got these messages.

About this lockdep error - I see it for very long time and it appears
always (see end of serial log here:
https://krzk.eu/#/builders/21/builds/707/steps/10/logs/serial0). It
started much before this issue came so I am not sure whether it is
related.

Best regards,
Krzysztof
