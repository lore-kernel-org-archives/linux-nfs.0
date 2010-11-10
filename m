From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: kernel panic with 2.6.37-rc1 +pnfs
Date: Wed, 10 Nov 2010 16:06:49 +0200
Message-ID: <4CDAA6F9.7080305@panasas.com>
References: <4CD95DB5.2030006@desy.de> <4CDA74F5.90700@panasas.com> <4CDAA47C.2040705@desy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og101.obsmtp.com ([64.18.0.141]:49676 "HELO
	exprod5og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755816Ab0KJOGw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 09:06:52 -0500
In-Reply-To: <4CDAA47C.2040705@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-10 15:56, Tigran Mkrtchyan wrote:
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> I guess that ff8b16d vmstat: fix offset calculation on void*
>> could fix this problem.  It's currently in Linus's master branch
>> and he hasn't released 2.6.37-rc2 yet.
>> Can you please try to reproduce the problem you saw with this patch?
> 
> Yes, that was the fix! I will update our cluster and re-run productions jobs
> with new kernel.

Cool.  I'm glad it helped!

Benny

> 
> Thanks,
>    TIgran.
> 
>>
>> Benny
