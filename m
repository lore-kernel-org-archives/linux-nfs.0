Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-3.desy.de ([131.169.56.86]:64581 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab1AQPim (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jan 2011 10:38:42 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 7C39814B5
	for <linux-nfs@vger.kernel.org>; Mon, 17 Jan 2011 16:38:41 +0100 (MET)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 4EFA014B4
	for <linux-nfs@vger.kernel.org>; Mon, 17 Jan 2011 16:38:40 +0100 (MET)
Message-ID: <4D3462A8.2070406@desy.de>
Date: Mon, 17 Jan 2011 16:39:20 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfsv4 + readdir == too many requests
References: <4D2F5FE1.6050509@desy.de> <1294952462.3038.29.camel@heimdal.trondhjem.org> <4D2F6B3D.7080007@desy.de>
In-Reply-To: <4D2F6B3D.7080007@desy.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Still didn't got a time to test with vanilla kernel. But got some details.
It's works as expected with sec=sys. With sec=krb5 I see this effect.
Unfortunately kernel crashes as soon as I try to re-run tests. It simply
freezes with no stack traces....

Regards,
    Tigran

On 01/13/2011 10:14 PM, Tigran Mkrtchyan wrote:
> On 01/13/2011 10:01 PM, Trond Myklebust wrote:
>> On Thu, 2011-01-13 at 21:26 +0100, Tigran Mkrtchyan wrote:
>>
>>> By running intensive tests I notice that readdir oration over nfsv4.1
>>> asks for
>>> file attributes in readdir (attr_request) and later on for each file. To
>>> me it looks like
>>> broken.
>>>
>>> This 2.6.37 + pnfs-all-latests :
>>>
>>> git://linux-nfs.org/~bhalevy/linux-pnfs.git
>>> 378978453b64bf895de8cd0e68dbcd9e9c0155ce
>>>
>>> 100% reproducible.
>>>
>> 1) What makes you think this is broken, and not just a case of the
>> attribute cache timing out and/or the directory changing?
>>
> The directory does not changed. I issue 'ls -l' and with wireshak can
> see READDIR requests
> followed by GETATTR. looks like cache is ignored or too small.
>> 2) Can you produce a testcase that proves brokenness?
>>
> I will try to come up with something.
>> 3) Can you reproduce on a non-pnfs-all-latests kernel?
>>
>> Readdir shouldn't be affected by the stuff in Benny's tree, but I'm
>> always wary of tests on out-of-mainline trees.
>>
> NP. with vanilla 2.6.37 ?
>
> Regards,
>     Tigran.
>> Cheers
>>     Trond
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

