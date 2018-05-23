Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:37198 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932844AbeEWNZg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2018 09:25:36 -0400
Received: by mail-vk0-f46.google.com with SMTP id m144-v6so13117021vke.4
        for <linux-nfs@vger.kernel.org>; Wed, 23 May 2018 06:25:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <YTOPR0101MB0953F9A6FE17FCD371233EC1DD6B0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
 <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de> <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
 <YTOPR0101MB0953F9A6FE17FCD371233EC1DD6B0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 23 May 2018 09:25:34 -0400
Message-ID: <CAN-5tyHRj3F1=Xjdkj5TsX62kH7jtAZZGv9fSLVSoRh5QxUFAw@mail.gmail.com>
Subject: Re: question: re-try of operations in PNFS
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 8:26 PM, Rick Macklem <rmacklem@uoguelph.ca> wrote:
> Olga Kornievskaia wrote:
> [good stuff snipped]
>>Upstream kernel. But I'm arguing that there shouldn't be a need to
>>specify a dataserver_timeo because it shouldn't timeout at all just
>>like MDS operations.
> If/when the server is providing mirrored DSs, I've found this timeout useful
> in the FreeBSD client since it allows the client to detect a DS failure.
> It can then report the failure to the MDS via LayoutReturn (or another one
> on NFSv4.2 which I can't remember the name of since I haven't done 4.2;-).
>
> For non-mirrored DSs, the only thing I can think of (I've never seen this) would
> be some sort of network partitioning such that the client can't reach the DS but
> can reach the MDS.
>
> I have no idea if this is relevant to Linux, but thought I'd mention it, just in case.
> [more stuff snipped]

Isn't retrying makes the implementation not spec compliant?
