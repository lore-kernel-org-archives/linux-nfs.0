Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46703 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab2CBNlg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 08:41:36 -0500
Received: by vcqp1 with SMTP id p1so1439567vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 05:41:35 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <1330695581.23200.73.camel@lade.trondhjem.org>
References: <CAGue13pLLJg+xcSyn-mC9-yPrsvPTEwKz0b_vY+Mm3X_i6VEvw@mail.gmail.com>
	<1330695581.23200.73.camel@lade.trondhjem.org>
Date: Fri, 2 Mar 2012 14:41:35 +0100
Message-ID: <CAGue13qqDC2cvhyJZVknnYDaso-drUUT31dgcZp5uF0wCGccKA@mail.gmail.com>
Subject: Re: invalid sequence id
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.

On Fri, Mar 2, 2012 at 2:39 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2012-03-02 at 14:32 +0100, Tigran Mkrtchyan wrote:
>> According rfc5661 section 2.10..6.1:
>>
>>
>>  The first time a slot is used, the requester MUST specify a  sequence
>> ID of one.
>>
>> Nevertheless, current client (git://linux-nfs.org/~trondmy/nfs-2.6.git
>> abd96698613eb27415e7028b6100be930920adc6)
>>
>> sends starts with zero:
>>
>>
>> fedora kernel 3.2.7 does it correct.
>
> That issue is fixed in upstream. I will back-merge to the nfs-for-next
> soon, in the meantime, try using the linux-next branch which already has
> a back-merge of the fix.
>
> Cheers
>  Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
