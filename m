Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-3.desy.de ([131.169.56.86]:56769 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0IFU1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Sep 2010 16:27:52 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 3494710C5
	for <linux-nfs@vger.kernel.org>; Mon,  6 Sep 2010 21:54:41 +0200 (MEST)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 1BAC61044
	for <linux-nfs@vger.kernel.org>; Mon,  6 Sep 2010 21:54:41 +0200 (MEST)
Message-ID: <4C8546FE.2080304@desy.de>
Date: Mon, 06 Sep 2010 21:54:38 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [pnfs] kernel panic
References: <4C80EC83.1030606@desy.de> <4C854019.6030108@panasas.com>
In-Reply-To: <4C854019.6030108@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Benny,

I was listening my mp3 music over pnfs. at some point my machine crashed
( I restarted pnfs data server). The kernel stack traces where the last
entries in the
message file. Up to now I have seen only few kernel panics. We transfer
couple of TB and run more than 150 concurrent applications. Usually
in case of problems clients becomes inaccessible, but I am able to
reboot them. This time my desktop simply hangs and I have to power cycle it.

Regards,
   Tigran.


On 09/06/2010 09:25 PM, Benny Halevy wrote:
> Tigran, was there an actual panic or just this string of WARNINGs?
> Were there any ill effects for this warning?
> The reason I'm asking is that according to our latest analysis of the
> code the warning might be a red herring and it can happen in valid scenarios
> so we intend to remove it altogether in the revised pnfs-submit series.
>
> Thanks for reporting in any case!
>
> Benny
>
> On 2010-09-03 15:39, Tigran Mkrtchyan wrote:
>   
>>   FYI
>>
>> kernel pnfs-all-2.6.35-2010.08-24 (git 
>> fa5a03da84b02026396be0736288b3f4a8143ff2)
>>
>>
>> Regards,
>>      Tigran.
>>
>>
>>
>> _______________________________________________
>> NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org
>> instead.  (To subscribe to linux-nfs@vger.kernel.org: send "subscribe
>> linux-nfs" in the body of a message to majordomo@vger.kernel.org.)
>>
>> pNFS mailing list
>> pNFS@linux-nfs.org
>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>>     
>   

