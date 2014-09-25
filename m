Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4.blacknight.com ([78.153.203.207]:43983 "EHLO
	relay4.blacknight.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbaIYJqM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 05:46:12 -0400
Message-ID: <5423E461.8020108@mpstor.com>
Date: Thu, 25 Sep 2014 10:46:09 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: NeilBrown <neilb@suse.de>
Subject: Re: NFS auto-reconnect tuning.
References: <5422E5CB.6000402@mpstor.com> <20140925114452.121776c0@notabene.brown>
In-Reply-To: <20140925114452.121776c0@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25/09/14 02:44, NeilBrown wrote:
> On Wed, 24 Sep 2014 16:39:55 +0100 Benjamin ESTRABAUD <be@mpstor.com> wrote:
>
>> Hi!
>>
>> I've got a scenario where I'm connected to a NFS share on a client, have
>> a file descriptor open as read only (could also be write) on a file from
>> that share, and I'm suddenly changing the IP address of that client.
>>
>> Obviously, the NFS share will hang, so if I now try to read the file
>> descriptor I've got open (here in Python), the "read" call will also hang.
>>
>> However, the driver seems to attempt to do something (maybe
>> save/determine whether the existing connection can be saved) and then,
>> after about 20 minutes the driver transparently reconnects to the NFS
>> share (which is what I wanted anyways) and the "read" call instantiated
>> earlier simply finishes (I don't even have to re-open the file again or
>> even call "read" again).
>>
>> The dmesg prints I get are as follow:
>>
>> [ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <--
>> changed IP address and started reading the file.
>> [ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was
>> reconnected, the "read" call completes successfully.
>
> The difference between these timestamps is 27 seconds, which is a lot less
> than the "20 minutes" that you quote.  That seems odd.
>
Hi Neil,

My bad, I had made several attempts and must have copied the wrong dmesg 
trace. The above happened when I manually reverted the IP config back to 
its original address (when doing so the driver reconnects immediately).

Here is what had happened:

[ 1663.940406] nfs: server 10.0.2.17 not responding, still trying
[ 2712.480325] nfs: server 10.0.2.17 OK

> If you adjust
>     /proc/sys/net/ipv4/tcp_retries2
>
> you can reduce the current timeout.
> See Documentation/networking/ip-sysctl.txt for details on the setting.
>
> https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
>
> It claims the default gives an effective timeout of 924 seconds or about 15
> minutes.
>
> I just tried and the timeout was 1047 seconds. This is probably the next
> retry after 924 seconds.
>
> If I reduce tcp_retries2 to '3' (well below the recommended minimum) I get
> a timeout of 5 seconds.
> You can possibly find a suitable number that isn't too small...
>
That's very interesting! Thank you very much! However, I'm a bit worried 
when changing the whole TCP stack settings, NFS is only one small chunk 
of a much bigger network storage box, so if there are alternative it'll 
probably be better. Also I would need a very very small timeout, in the 
order of 10-20 secs *max* so that would probably cause other issues 
elsewhere, but this is very interesting indeed.

> Alternately you could use NFSv4.  It will close the connection on a timeout.
> In the default config I measure a 78 second timeout, which is probably more
> acceptable.  This number would respond to the timeo mount option.
> If I set that to 100, I get a 28 second timeout.
>
This is great! I had no idea, I will definitely roll NFSv4 and try that. 
Thanks again for your help!

> The same effect could be provided for NFSv3 by setting:
>
>             __set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
>
> somewhere appropriate.  I wonder why that isn't being done for v3 already...
> Probably some subtle protocol difference.
If for some reason we can't stick to v4 we'll try that too, thanks.

>
> NeilBrown
>
>
Regards,

Ben - MPSTOR.

>> I would like to know if there was any way to tune this behaviour,
>> telling the NFS driver to reconnect if a share is unavailable after say
>> 10 seconds.
>>
>> I tried the following options without any success:
>>
>> retry=0; hard/soft; timeo=3; retrans=1; bg/fg
>>
>> I am running on a custom distro (homemade embedded distro, not based on
>> anything in particular) running stock kernel 3.10.18 compiled for i686.
>>
>> Would anyone know what I could do to force NFS into reconnecting a
>> seemingly "dead" session sooner?
>>
>> Thanks in advance for your help.
>>
>> Regards,
>>
>> Ben - MPSTOR.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

