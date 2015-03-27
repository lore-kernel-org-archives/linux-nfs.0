Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:34262 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030276AbbC0PB6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 11:01:58 -0400
Received: by yhch68 with SMTP id h68so39598285yhc.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 08:01:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2000185644.567074.1427466785581.JavaMail.zimbra@desy.de>
References: <CAABAsM4jh3+S0YjNiSf8xdru0at5vUkvJRsTUDuoVupZNp+JUA@mail.gmail.com>
	<2000185644.567074.1427466785581.JavaMail.zimbra@desy.de>
Date: Fri, 27 Mar 2015 11:01:57 -0400
Message-ID: <CAHQdGtRONXHKKC+c6FhDg2=Yxws0-c2g2PYe4OXyQz+jsZcnwQ@mail.gmail.com>
Subject: Re: pNFS layout, ROC and multiple opens
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 10:33 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
> which means that even I I set roc flag, I still need to recall layout.

No. It means that the layout is automatically returned on last close
and/or delegreturn. If you want it returned earlier then you need to
send a cb_layoutrecall.

> ----- Original Message -----
>> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
>> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>> Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>
>> Sent: Friday, March 27, 2015 3:08:39 PM
>> Subject: Re: pNFS layout, ROC and multiple opens
>
>> On Fri, Mar 27, 2015 at 7:24 AM, Mkrtchyan, Tigran
>> <tigran.mkrtchyan@desy.de> wrote:
>>>
>>>
>>> Hi folks,
>>>
>>> we run into following issue:
>>>
>>> on a client host we have two processes - A and B.
>>> Process A opens a file and reads some data:
>>>
>>> OPEN -> LAYOUTGET -> READ.
>>> Notice, that layout has a roc set to true.
>>>
>>> Process B opens the same file:
>>>
>>> OPEN -> READ.
>>>
>>> Client obviously re-used layout information.
>>> Now, process A closes the file and as a result,
>>> layout becomes invalid.
>>
>> No it doesn't. See the errata.
>>
>> Cheers
>>   Trond



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
