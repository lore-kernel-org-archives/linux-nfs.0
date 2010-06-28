From: "Jasper Mackenzie" <jasper.mackenzie@gmail.com>
Subject: Re: Problem: Clients freeze on transfer of large files, w gigabit lan
Date: Tue, 29 Jun 2010 07:45:32 +1200
Message-ID: <op.ve0zt0xmo2qfwp@foundation>
References: <op.vet93peko2qfwp@foundation>
 <1277491873.6141.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44453 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab0F1Tpv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 15:45:51 -0400
Received: by pwj8 with SMTP id 8so3480241pwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jun 2010 12:45:51 -0700 (PDT)
In-Reply-To: <1277491873.6141.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>     I and many others have been plagued by a problem that can be  
>> summarised
>> as follows:
>>
>> Client hangs upon copying of large files TO the server. Transfer begins
>> quickly then hangs, sometimes taking the client o/s with it, until
>> transfer starts again. In less extreme cases transfer is sporadic.
>>     I am using nfs4 w gigabit nics.
>> http://ubuntuforums.org/showthread.php?p=9269703
>>     It appears that this problem is not restricted to ubuntu and exists
>
> Could this perhaps be related to the following bugzilla entry?
>     https://bugzilla.kernel.org/show_bug.cgi?id=16213
>
> If so, then could you please try the proposed fix and see if it helps.
>
> Cheers
>   Trond
  Thanks Trond,
The patch solved the client lockups with a patched vanilla kernel (will  
keep trying with an ubuntu kernel, as it should do the same, but didnt)

Unfortunatley it dousnt fix the other problem, as it seems they are  
separate, of the transfer happening in bursts, reducing the actual  
throughput dramatically. i.e transfer starts at 16mb/s (according to  
nautilus), then 3 or 4 seconds later the progress bar stops, the hdd  
activity also stops (its the same with cp of course, nautilus just gives  
me a good indication of xfer speed), then 4 or 5 seconds later it starts  
again for 3 or 4 seconds.... repeat ad nausium...
  Refer to the forum thread for graphs etc. of throughput if nesc.

  Thanks.

Jasper
