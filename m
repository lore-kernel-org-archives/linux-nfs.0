Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:51953 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756627AbbFPOYB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2015 10:24:01 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 8D3BB28040A
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 16:23:59 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 7A15F13E96
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 16:23:59 +0200 (MEST)
Date: Tue, 16 Jun 2015 16:23:59 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1932150629.4020987.1434464639025.JavaMail.zimbra@desy.de>
In-Reply-To: <1131665268.4008393.1434459923077.JavaMail.zimbra@desy.de>
References: <1857695394.3971135.1434449335470.JavaMail.zimbra@desy.de> <CAHQdGtRN39m1UDFMbMn+35Wp=1L9XZYJAgYpZ850qgypcGKjJg@mail.gmail.com> <1131665268.4008393.1434459923077.JavaMail.zimbra@desy.de>
Subject: Re: crash on read overflow
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

:( I added

c337d3655 SUNRPC: xdr_read_pages should return the amount of XDR encoded page data

But it still crashes.

Tigran.

----- Original Message -----
> From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> To: "Trond Myklebust" <trond.myklebust@primarydata.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Tuesday, June 16, 2015 3:05:23 PM
> Subject: Re: crash on read overflow

> Hi Trond,
> 
> Yes, I already have discovered rpc level dependencies as well
> and testing a minnimal patch set for RHEL6.
> 
> Thanks,
>  Tigran.
> 
> ----- Original Message -----
>> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
>> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
>> Sent: Tuesday, June 16, 2015 2:32:04 PM
>> Subject: Re: crash on read overflow
> 
>> Hi Tigran,
>> 
>> On Tue, Jun 16, 2015 at 6:08 AM, Mkrtchyan, Tigran
>> <tigran.mkrtchyan@desy.de> wrote:
>>>
>>>
>>> Hi Trond,
>>>
>>> with RHEL6 kernel we observe kernel panic if server reply
>>> more data than client requested. This is obviously fixed in
>>> RHEL7 and upstream. Unfortunately, kernel crashes so badly
>>> that I can't get any stacktrace. My guess is that
>>> commit 64bd577ea0021f5903505de061b3b7d8a785ee94 is the one
>>> which fixes the issue. Can you confirm?
>>>
>> 
>> That should help, but you also need to ensure that they have applied
>> commit bfeea1dc1c92 ("SUNRPC: Don't decode beyond the end of the RPC
>> reply message").
>> 
>> You might possibly also need commit 1537693ceaa8 ("SUNRPC: Clean up
>> xdr_set_iov()") and commit 76cacaabf15a ("SUNRPC: xdr_read_pages needs
>> to clear xdr->page_ptr.") since those are all dependencies for
>> bfeea1dc1c92.
>> 
>> Cheers
>>  Trond
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
