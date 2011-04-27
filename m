From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: Re: pNFS kernel for Fedora 15
Date: Wed, 27 Apr 2011 15:59:39 +0200
Message-ID: <4DB8214B.9000603@desy.de>
References: <4DB05BB3.8080706@desy.de> <4DB2C0A7.6090501@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:45034 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509Ab1D0OBI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 10:01:08 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id AB1C318EB
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2011 16:01:06 +0200 (MEST)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id A058D13ED2
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2011 16:01:06 +0200 (MEST)
In-Reply-To: <4DB2C0A7.6090501-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The build for fc16 looks like OK.

Tigran.

On 04/23/2011 02:05 PM, Steve Dickson wrote:
>
> On 04/21/2011 12:30 PM, Tigran Mkrtchyan wrote:
>> Hi Steve et. al.
>>
>> it looks like kernel fails to correctly work with
>> rpc.gssd if some of kernel modules statically
>> compiled:
>>
>> BAD (pnfs kernel from Steve):
>> CONFIG_SUNRPC_GSS=m
>> CONFIG_RPCSEC_GSS_KRB5=y
>>
>> in messages:
>> [  537.544188] gss_create: Pseudoflavor 390003 not found!
>> [  537.544236] RPC: Couldn't create auth handle (flavor 390003)
>>
>>
>> GOOD (fedora native kernel or my own build):
>> CONFIG_SUNRPC_GSS=m
>> CONFIG_RPCSEC_GSS_KRB5=m
>>
>> Steve, could you build new kernel with CONFIG_RPCSEC_GSS_KRB5=m ?
>>
>>
>> BTW, there was a similar issue with nfsd discussed last couple of days.
>> http://www.spinics.net/lists/linux-nfs/msg20617.html
> I'll take a look... thanks!
>
> steved.

