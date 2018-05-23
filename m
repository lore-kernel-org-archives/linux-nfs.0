Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:39493 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933718AbeEWPQI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2018 11:16:08 -0400
Received: by mail-ua0-f196.google.com with SMTP id v17-v6so15007518uak.6
        for <linux-nfs@vger.kernel.org>; Wed, 23 May 2018 08:16:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5be0737d7bcb70f437a5db6b727b48f5992b96ae.camel@hammerspace.com>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
 <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de> <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
 <YTOPR0101MB0953F9A6FE17FCD371233EC1DD6B0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
 <CAN-5tyHRj3F1=Xjdkj5TsX62kH7jtAZZGv9fSLVSoRh5QxUFAw@mail.gmail.com> <5be0737d7bcb70f437a5db6b727b48f5992b96ae.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 23 May 2018 11:16:06 -0400
Message-ID: <CAN-5tyGW5weSJHLG684eOi6=cAwLAu8e7T69f+J2v+S-mcGM+w@mail.gmail.com>
Subject: Re: question: re-try of operations in PNFS
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "rmacklem@uoguelph.ca" <rmacklem@uoguelph.ca>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 23, 2018 at 9:42 AM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
> On Wed, 2018-05-23 at 09:25 -0400, Olga Kornievskaia wrote:
>> On Tue, May 22, 2018 at 8:26 PM, Rick Macklem <rmacklem@uoguelph.ca>
>> wrote:
>> > Olga Kornievskaia wrote:
>> > [good stuff snipped]
>> > > Upstream kernel. But I'm arguing that there shouldn't be a need
>> > > to
>> > > specify a dataserver_timeo because it shouldn't timeout at all
>> > > just
>> > > like MDS operations.
>> >
>> > If/when the server is providing mirrored DSs, I've found this
>> > timeout useful
>> > in the FreeBSD client since it allows the client to detect a DS
>> > failure.
>> > It can then report the failure to the MDS via LayoutReturn (or
>> > another one
>> > on NFSv4.2 which I can't remember the name of since I haven't done
>> > 4.2;-).
>> >
>> > For non-mirrored DSs, the only thing I can think of (I've never
>> > seen this) would
>> > be some sort of network partitioning such that the client can't
>> > reach the DS but
>> > can reach the MDS.
>> >
>> > I have no idea if this is relevant to Linux, but thought I'd
>> > mention it, just in case.
>> > [more stuff snipped]
>>
>> Isn't retrying makes the implementation not spec compliant?
>
> Replaying a request would not be spec compliant. Playing new requests
> is perfectly fine (e.g. after picking up a new layout or redirecting
> the I/O to the MDS).

I see you are right. The request to the MDS is a "new request" as it
uses a different filehandle.

> Historically, I seem to remember that at one point we introduced a 15s
> timeout on I/O requests to the DS in order to allow fast failover of
> the pNFS client when the DS was down or unresponsive. I'm not sure
> whether or not that mechanism still exists and whether it is what you
> are seeing here.

Then I'd guess it probably is that and the timeout now is 10s.
