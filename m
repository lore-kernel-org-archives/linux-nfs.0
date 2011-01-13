Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:43458 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756691Ab1AMVOa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 16:14:30 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id EFB7B19A2
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 22:14:28 +0100 (MET)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id E978113F23
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 22:14:28 +0100 (MET)
Message-ID: <4D2F6B3D.7080007@desy.de>
Date: Thu, 13 Jan 2011 22:14:37 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfsv4 + readdir == too many requests
References: <4D2F5FE1.6050509@desy.de> <1294952462.3038.29.camel@heimdal.trondhjem.org>
In-Reply-To: <1294952462.3038.29.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/13/2011 10:01 PM, Trond Myklebust wrote:
> On Thu, 2011-01-13 at 21:26 +0100, Tigran Mkrtchyan wrote: 
>   
>> By running intensive tests I notice that readdir oration over nfsv4.1
>> asks for
>> file attributes in readdir (attr_request) and later on for each file. To
>> me it looks like
>> broken.
>>
>> This 2.6.37 + pnfs-all-latests :
>>
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git
>> 378978453b64bf895de8cd0e68dbcd9e9c0155ce
>>
>> 100% reproducible.
>>     
> 1) What makes you think this is broken, and not just a case of the
> attribute cache timing out and/or the directory changing?
>   

The directory does not changed. I issue 'ls -l' and with wireshak can
see READDIR requests
followed by GETATTR. looks like cache is ignored or too small.
> 2) Can you produce a testcase that proves brokenness?
>   
I will try to come up with something.
> 3) Can you reproduce on a non-pnfs-all-latests kernel?
>
> Readdir shouldn't be affected by the stuff in Benny's tree, but I'm
> always wary of tests on out-of-mainline trees.
>   
NP. with vanilla 2.6.37 ?

Regards,
   Tigran.
> Cheers
>    Trond
>   

