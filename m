Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:63945 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbZIBT1G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 15:27:06 -0400
Received: by pzk42 with SMTP id 42so968841pzk.19
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2009 12:27:09 -0700 (PDT)
In-Reply-To: <e7ca40f70909021210p646e2635l267ac6def345b4c7@mail.gmail.com>
References: <20090902180841.GF946@proxime.net>
	 <e7ca40f70909021119r2f49724dj705e334cf1ae9b3a@mail.gmail.com>
	 <1f808b4a0909021135m49c2e60o6b305babcaed295c@mail.gmail.com>
	 <e7ca40f70909021210p646e2635l267ac6def345b4c7@mail.gmail.com>
Date: Thu, 3 Sep 2009 00:57:09 +0530
Message-ID: <1f808b4a0909021227k768695dbm66fbd4022f1b5b91@mail.gmail.com>
Subject: Re: NFS for millions of files
From: Peter Chacko <peterchacko35@gmail.com>
To: Aaron Wiebe <epiphani@gmail.com>
Cc: Jason Legate <linux-nfs@proxime.net>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Of course fragmentation doesn't matter if there is no data IO...You
true...I usually got significant performance with rszie/wsize around
4K, while MTU was at 1.5 k.....As you said right balance  between the
performance gains at the RPC/UDP stack and fragmentation overhead at
L3/L2 stack....

May be you can try adding more threads on the server, and if it is
MIPIO capable, you can find better performance....and lastly NFS is
not meant for performance...Until you use NFSoRDMA pr pNFS....As Chuck
mentioned, sequential LOG based file systems based NFS server  offer
better performance at a server storage level..

And if you have a real need, i  have created an NFS load balancer that
 brings superior performance(better than local FS for large meta data
intensive workloads or IO is spread to different files) for my
previous employer...You can find more details here.. Its not open
source...But i can have them contact you and give you a trial
version...

http://www.calsoftlabs.com/whitepapers/net-nfs.html

thanks

On Thu, Sep 3, 2009 at 12:40 AM, Aaron Wiebe<epiphani@gmail.com> wrote:
> On Wed, Sep 2, 2009 at 2:35 PM, Peter Chacko<peterchacko35@gmail.com> wrote:
>> Is this NFSv4 ?  rsize and wsize > MTU size will cause fragmentation
>> and performance issues...Try making it around 4k .....You used  1<<15
>> fir your example. if you don't do writes....then this shouldn't
>> matter...and of course NFS is  Nfs is not For Scalability.. You cannot
>> get the same performance on NFS as you would get for localFS...May be
>> you can try 10g....still there is TCP/UDP/IP stack overhead.....
>
> Fragmentation won't hurt you that much, and it doesn't even apply to
> opens, since those operations are significantly smaller.  The
> performance gains higher in the stack from a larger rsize/wsize
> generally outweigh the savings in frame size optimization.  Of course,
> jumbo frames are always a good idea, but again, doesn't help here.
>
> -Aaron
>



-- 
Best regards,
Peter Chacko

NetDiox computing systems,
Network storage & OS  training and research.
Bangalore, India.
www.netdiox.com
080 2664 0708
