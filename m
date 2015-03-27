Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:37954 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbbC0OdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 10:33:08 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 98973280AEE
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 15:33:06 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 8C78A15EC
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 15:33:06 +0100 (MET)
Date: Fri, 27 Mar 2015 15:33:05 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-ID: <2000185644.567074.1427466785581.JavaMail.zimbra@desy.de>
In-Reply-To: <CAABAsM4jh3+S0YjNiSf8xdru0at5vUkvJRsTUDuoVupZNp+JUA@mail.gmail.com>
References: <CAABAsM4jh3+S0YjNiSf8xdru0at5vUkvJRsTUDuoVupZNp+JUA@mail.gmail.com>
Subject: Re: pNFS layout, ROC and multiple opens
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

which means that even I I set roc flag, I still need to recall layout.

----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>
> Sent: Friday, March 27, 2015 3:08:39 PM
> Subject: Re: pNFS layout, ROC and multiple opens

> On Fri, Mar 27, 2015 at 7:24 AM, Mkrtchyan, Tigran
> <tigran.mkrtchyan@desy.de> wrote:
>>
>>
>> Hi folks,
>>
>> we run into following issue:
>>
>> on a client host we have two processes - A and B.
>> Process A opens a file and reads some data:
>>
>> OPEN -> LAYOUTGET -> READ.
>> Notice, that layout has a roc set to true.
>>
>> Process B opens the same file:
>>
>> OPEN -> READ.
>>
>> Client obviously re-used layout information.
>> Now, process A closes the file and as a result,
>> layout becomes invalid.
> 
> No it doesn't. See the errata.
> 
> Cheers
>   Trond
