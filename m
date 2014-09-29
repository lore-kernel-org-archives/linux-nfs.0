Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4.blacknight.com ([78.153.203.207]:36532 "EHLO
	relay4.blacknight.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaI2KG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Sep 2014 06:06:29 -0400
Message-ID: <54292F22.9050606@mpstor.com>
Date: Mon, 29 Sep 2014 11:06:26 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS auto-reconnect tuning.
References: <5422E5CB.6000402@mpstor.com>	<20140925114452.121776c0@notabene.brown>	<5423E461.8020108@mpstor.com> <20140929092836.6de0fd92@notabene.brown>
In-Reply-To: <20140929092836.6de0fd92@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29/09/14 00:28, NeilBrown wrote:
> On Thu, 25 Sep 2014 10:46:09 +0100 Benjamin ESTRABAUD <be@mpstor.com> wrote:
>
>> On 25/09/14 02:44, NeilBrown wrote:
>>> On Wed, 24 Sep 2014 16:39:55 +0100 Benjamin ESTRABAUD <be@mpstor.com> wrote:
>>>
>>>> Hi!
>>>>
>>>> I've got a scenario where I'm connected to a NFS share on a client, have
>>>> a file descriptor open as read only (could also be write) on a file from
>>>> that share, and I'm suddenly changing the IP address of that client.
>>>>
>>>> Obviously, the NFS share will hang, so if I now try to read the file
>>>> descriptor I've got open (here in Python), the "read" call will also hang.
>>>>
>>>> However, the driver seems to attempt to do something (maybe
>>>> save/determine whether the existing connection can be saved) and then,
>>>> after about 20 minutes the driver transparently reconnects to the NFS
>>>> share (which is what I wanted anyways) and the "read" call instantiated
>>>> earlier simply finishes (I don't even have to re-open the file again or
>>>> even call "read" again).
>>>>
>>>> The dmesg prints I get are as follow:
>>>>
>>>> [ 4424.500380] nfs: server 10.0.2.17 not responding, still trying <--
>>>> changed IP address and started reading the file.
>>>> [ 4451.560467] nfs: server 10.0.2.17 OK <--- The NFS share was
>>>> reconnected, the "read" call completes successfully.
>>>
>>> The difference between these timestamps is 27 seconds, which is a lot less
>>> than the "20 minutes" that you quote.  That seems odd.
>>>
>> Hi Neil,
>>
>> My bad, I had made several attempts and must have copied the wrong dmesg
>> trace. The above happened when I manually reverted the IP config back to
>> its original address (when doing so the driver reconnects immediately).
>>
>> Here is what had happened:
>>
>> [ 1663.940406] nfs: server 10.0.2.17 not responding, still trying
>> [ 2712.480325] nfs: server 10.0.2.17 OK
>>
>>> If you adjust
>>>      /proc/sys/net/ipv4/tcp_retries2
>>>
>>> you can reduce the current timeout.
>>> See Documentation/networking/ip-sysctl.txt for details on the setting.
>>>
>>> https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
>>>
>>> It claims the default gives an effective timeout of 924 seconds or about 15
>>> minutes.
>>>
>>> I just tried and the timeout was 1047 seconds. This is probably the next
>>> retry after 924 seconds.
>>>
>>> If I reduce tcp_retries2 to '3' (well below the recommended minimum) I get
>>> a timeout of 5 seconds.
>>> You can possibly find a suitable number that isn't too small...
>>>
>> That's very interesting! Thank you very much! However, I'm a bit worried
>> when changing the whole TCP stack settings, NFS is only one small chunk
>> of a much bigger network storage box, so if there are alternative it'll
>> probably be better. Also I would need a very very small timeout, in the
>> order of 10-20 secs *max* so that would probably cause other issues
>> elsewhere, but this is very interesting indeed.
>>
>>> Alternately you could use NFSv4.  It will close the connection on a timeout.
>>> In the default config I measure a 78 second timeout, which is probably more
>>> acceptable.  This number would respond to the timeo mount option.
>>> If I set that to 100, I get a 28 second timeout.
>>>
>> This is great! I had no idea, I will definitely roll NFSv4 and try that.
>> Thanks again for your help!
>
> Actually ... it turns out that NFSv4 shouldn't close the connection early
> like that.  It happens due to a bug which is now being fixed :-)
Well, maybe I could "patch" NFSv4 here for my purpose or use the patch 
you provided before for NFSv3, although I admit it would be easier to 
use a stock kernel if possible.
>
> Probably the real problem is that the TCP KEEPALIVE feature isn't working
> properly.  NFS configures it so that keep-alives are sent at the 'timeout'
> time and the connection should close if a reply is not seen fairly soon.
>
I wouldn't mind using TCP Keepalives but I am worried that I'd have to 
change a TCP wide setting, which other applications might rely on (I 
read that the TCP keepalive time for instance should be no less than 2 
hours). Could NFS just have a "custom" TCP keepalive and leave the 
global, default setting untouched?

> However TCP does not send keepalives when the are packets in the queue
> waiting to go out (which is appropriate) and also doesn't check for timeouts
> problem when the queue is full.
>
So if I understand correctly, the keepalives are sent when the 
connection is completely idle, but if the connection break happened 
during a transfer (queue not empty) then NFS would never find out as it 
wouldn't send anymore keepalives?

> I'll post to net-dev asking if I've understood this correctly and will take
> the liberty of cc:ing you.
Thank you very much for this, this will help.

>
> NeilBrown
>
>
Ben - MPSTOR

