Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:34044 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbbFRMx7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 08:53:59 -0400
Received: by ykfl8 with SMTP id l8so65091801ykf.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 05:53:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5582B960.7000301@control.lth.se>
References: <55827B8D.3070103@control.lth.se>
	<CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
	<5582B960.7000301@control.lth.se>
Date: Thu, 18 Jun 2015 08:53:59 -0400
Message-ID: <CAHQdGtQddKrKgoNiLyzJMupCYyVn=HUDGtXucYD+tzOhnmrD_Q@mail.gmail.com>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anders Blomdell <anders.blomdell@control.lth.se>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2015 at 8:28 AM, Anders Blomdell
<anders.blomdell@control.lth.se> wrote:
> On 2015-06-18 13:49, Trond Myklebust wrote:
>> On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
>> <anders.blomdell@control.lth.se> wrote:
>>>
>>> I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
>>> due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
>>> https://bugzilla.redhat.com/show_bug.cgi?id=1228272.
>>
>>
>> Why should we change the clients if the server is in clear and obvious
>> violation of the spec?
> In order to make clients work with servers that worked well with previous versions
> of nfs-utils, the cultprit probably being commit f9802988 that bumped the default
> autonegotion version to 4.2, what the patch does is only to negotiate a lower version
> in case of errors, and hence making 1.3.2 working with servers that worked with
> 1.3.1 (that only tried version 4[.0]).
>
> Will probably save some people some time.

This is what /etc/nfsmount.conf is for. We don't fix clients that are
working correctly according to the protocol spec.

Trond
