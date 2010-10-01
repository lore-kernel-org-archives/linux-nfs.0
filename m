Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37524 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754324Ab0JAU7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 16:59:50 -0400
Message-ID: <4CA64BC3.8040404@panasas.com>
Date: Fri, 01 Oct 2010 22:59:47 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Jim Rees <rees@umich.edu>, Steve Dickson <SteveD@redhat.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: Updated pNFS Developmental kernel repository
References: <4CA5C059.6000805@RedHat.com>	<4CA5E744.9010006@desy.de>	<4CA63D1A.5070108@RedHat.com>	<20101001200747.GA4353@merit.edu> <AANLkTin9+_aWyLMv1xP9ou1YRXfY46dgK7J-to+p5LTb@mail.gmail.com>
In-Reply-To: <AANLkTin9+_aWyLMv1xP9ou1YRXfY46dgK7J-to+p5LTb@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-01 22:13, Fred Isaman wrote:
> On Fri, Oct 1, 2010 at 4:07 PM, Jim Rees <rees@umich.edu> wrote:
>> Steve Dickson wrote:
>>
>>  On 10/01/2010 09:51 AM, Tigran Mkrtchyan wrote:
>>  >
>>  > Hi Steve,
>>  >
>>  > thanks for the builds. What I am missing is modprobe configuration file
>>  > which I have to add myself.
>>  Unfortunately yes... I have not figured out a good way to have
>>  the mobprobe done on the client since, in general, init scripts
>>  don't run on the client (with the exception of rpc.statd and rpc.gssd).
>>
>>  I guess I could come up with an pnfs init script..but that
>>  seems like a bit overkill just to do a modprobe...
>>
>> I've already got an init script for the block layout client that does the
>> modprobe and starts the daemon.  How about we generalize it to modprobe the
>> other modules too, and call it the pnfs init script?
> 
> The current code is designed to request the loading of the module as
> needed.  All that is needed is an alias, of the type
> 
> alias nfs-layouttype4-[INTEGER_ID] ACTUAL_MODULE_NAME

I think that's too complicated.
Why not export a well known symbol from the layout driver,
encoding the layout type, to be looked up by the kernel?

Benny

> 
> Fred
> 
> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
