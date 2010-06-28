Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36688 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab0F1U2K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 16:28:10 -0400
Received: by pwj8 with SMTP id 8so3497613pwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jun 2010 13:28:10 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problem: Clients freeze on transfer of large files, w gigabit lan
References: <op.vet93peko2qfwp@foundation>
 <1277491873.6141.23.camel@heimdal.trondhjem.org>
 <op.ve0zt0xmo2qfwp@foundation> <1277755997.4433.8.camel@heimdal.trondhjem.org>
Date: Tue, 29 Jun 2010 08:27:54 +1200
From: "Jasper Mackenzie" <jasper.mackenzie@gmail.com>
Message-ID: <op.ve01ssl6o2qfwp@foundation>
In-Reply-To: <1277755997.4433.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


>> >>     I and many others have been plagued by a problem that can be
>> >> summarised
>> >> as follows:
>> >>
>> >> Client hangs upon copying of large files TO the server. Transfer  
>> begins
>> >> quickly then hangs, sometimes taking the client o/s with it, until
>> >> transfer starts again. In less extreme cases transfer is sporadic.
>> >>     I am using nfs4 w gigabit nics.
>> >> http://ubuntuforums.org/showthread.php?p=9269703
>> >>     It appears that this problem is not restricted to ubuntu and  
>> exists
>> >
>> > Could this perhaps be related to the following bugzilla entry?
>> >     https://bugzilla.kernel.org/show_bug.cgi?id=16213
>> >
>> > If so, then could you please try the proposed fix and see if it helps.
>> >
>> > Cheers
>> >   Trond
>>   Thanks Trond,
>> The patch solved the client lockups with a patched vanilla kernel (will
>> keep trying with an ubuntu kernel, as it should do the same, but didnt)
>>
>> Unfortunatley it dousnt fix the other problem, as it seems they are
>> separate, of the transfer happening in bursts, reducing the actual
>> throughput dramatically. i.e transfer starts at 16mb/s (according to
>> nautilus), then 3 or 4 seconds later the progress bar stops, the hdd
>> activity also stops (its the same with cp of course, nautilus just gives
>> me a good indication of xfer speed), then 4 or 5 seconds later it starts
>> again for 3 or 4 seconds.... repeat ad nausium...
>>   Refer to the forum thread for graphs etc. of throughput if nesc.
>
> That is usually because the server is caching too much data instead of
> progressively writing it out. When the client calls 'commit' (the NFS
> equivalent of fsync()) then the disk on the server goes into a frenzy of
> writing, and the client does the RPC equivalent of twiddling its thumbs
> until the server is done...
>
> I'd suggest trying to lower the values
> of /proc/sys/vm/dirty_expire_centisecs
> and /proc/sys/vm/dirty_background_ratio on the server. You might also
> try lowering /proc/sys/vm/dirty_writeback_centisecs...
>
> Cheers
>   Trond
  I reduced them to 10% of the value I found them at to 40,1,20  
respectivly, with no improvement.
I think I need to play with it more to see if the lockups are gone. Ime  
not sure if the original problem is quite fixed...
dammit. was too easy !

  When tested with ubuntu more, I will see how the ppl on the above forum  
go.

any other ideas?

Thanks

Jasper
