Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr660068.outbound.protection.outlook.com ([40.107.66.68]:63168
        "EHLO CAN01-QB1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751947AbeEMUpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 13 May 2018 16:45:02 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 client recovery of opens after server crash/reboot
Date: Sun, 13 May 2018 20:44:59 +0000
Message-ID: <YTOPR0101MB095342F796D66C79224906ADDD9D0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
References: <YTOPR0101MB095358258682ACC6D4F8DC02DD9E0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
         <YTOPR0101MB0953BA8247D49E4679F7AF67DD9D0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>,<c64b0f479f17120585412aa7fb44aadd20a08e6c.camel@hammerspace.com>
In-Reply-To: <c64b0f479f17120585412aa7fb44aadd20a08e6c.camel@hammerspace.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
>On Sun, 2018-05-13 at 12:12 +0000, Rick Macklem wrote:
>> I wrote:
>> > I just ran a little test of an NFSv4.1 server (FreeBSD) reboot
>> > while the Linux client
>> > had two files open over an NFSv4.1 mount (linux-4.17-rc2).
>> > It basically worked, but when I looked at the packet trace in
>> > wireshark, it wasn't what
>> > I expected.
>> > The operations were basically:
>> > 1 - ExchangeID
>> > 2 - CreateSession
>> > 3 - ReclaimComplete
>> > 4 - Open/Claim_FH done twice to reclaim the Opens
>> >
>> > This seems "unsafe" to me, since I think it would be possible for
>> > another client to >Open the file with OPEN_DENY_BOTH between #3 and
>> > #4, causing #4 to fail.
>> > I was expecting something like:
>> > 1 - ExchangeID
>> > 2 - CreateSession
>> > 3 - Open/Claim_previous done twice to reclaim the Opens
>> > 4 - ReclaimComplete
>>
>> I forgot to mention that this is probably not a serious issue right
>> now, since most
>> extant clients (FreeBSD and Linux I think?) always do Opens with
>> OPEN_SHARE_DENY_NONE.
>> The only current client I am aware of that does OPEN_SHARE_DENY_xx
>> other than
>> NONE is the ESXi 6.5 client. Btw, this client has serious issues that
>> I might post here, so the Linux server maintainers are aware of them.
>>
>
>Hi Rick,
>
>The Linux client will attempt to reclaim opens correctly (i.e. before
>sending RECLAIM_COMPLETE). However it will not attempt to reclaim any
>lock state if the server advertises a different identity after the
>reboot (see RFC5661, section 8.4.2.1.). Are you certain that the
>FreeBSD server is advertising the same  eir_server_owner and
>eir_server_scope fields after the reboot?
Ouch, yes, my mistake...
The eir_server_scope had changed.

Thanks and sorry for the noise, rick
ps: If I see a problem with the eir_server_scope the same, I'll post again, but
      I doubt that will happen.
