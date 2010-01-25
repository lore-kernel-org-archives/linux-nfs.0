From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs client performance while server is down
Date: Mon, 25 Jan 2010 16:01:00 -0500
Message-ID: <BE3111DF-6E15-4029-B939-BF6496F21D65@oracle.com>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com> <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com> <d7f0b3a81001230827y52727993nf60210ae610643b7@mail.gmail.com> <7A24DF798E223B4C9864E8F92E8C93EC0527810C@SACMVEXC1-PRD.hq.netapp.com> <d7f0b3a81001241609v35e54740yea3fa1a251b4f953@mail.gmail.com> <0BA6F612-CE3A-47E9-B436-57E48506D769@oracle.com> <d7f0b3a81001251102p5e631706jfd9f147a00487061@mail.gmail.com> <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com> <d7f0b3a81001251138h30e25428o25db9bc8c0884636@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Peter Chacko <peterchacko35@gmail.com>,
	linux-nfs@vger.kernel.org
To: Whoop Whouzer <tiredandnumb@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:17397 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab0AYVBb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2010 16:01:31 -0500
In-Reply-To: <d7f0b3a81001251138h30e25428o25db9bc8c0884636-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2010, at 2:38 PM, Whoop Whouzer wrote:
> Running  "strace nautilus" gives me allot of output. When I run it
> while the server is down it completes the trace without a hiccup, it
> returns and than nautilus is launched and hangs.
> There are differences between the traces (with server up and server
> down). I can't really see where the problem lies in there.

I would expect that the command-line nautilus forks when it starts  
up.  If it has some option you can specify to prevent that, it might  
allow a deeper look.  You would need to tell strace to look at the  
children, too.

> On Mon, Jan 25, 2010 at 8:08 PM, Chuck Lever  
> <chuck.lever@oracle.com> wrote:
>> On Jan 25, 2010, at 2:02 PM, Whoop Whouzer wrote:
>>>
>>> Ok, I did that, after shutting down the server and enabling debug
>>> trace I tried to open the home folder of the current account  
>>> (totally
>>> unrelated to the nfsshare), it wouldn't open at all, I got no  
>>> nautilus
>>> at all. During the time my cursor was in busy mode I got the  
>>> following
>>> messages in kern.log (for ubuntu 10.04 client):
>>> Jan 25 19:30:13 whoop-desktop kernel: [  160.719262] NFS call   
>>> fsstat
>>> Jan 25 19:30:37 whoop-desktop kernel: [  184.458611] NFS:
>>> permission(0:16/74386), mask=0x10, res=0
>>> Jan 25 19:30:37 whoop-desktop kernel: [  184.458647] NFS call   
>>> access
>>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721086] nfs: server
>>> 192.168.1.130 not responding, timed out
>>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721113] NFS reply  
>>> statfs: -5
>>> Jan 25 19:30:43 whoop-desktop kernel: [  190.721116] nfs_statfs:
>>> statfs error = 5
>>> These series of traces are repeating over and over again at a set
>>> interval (there is no flooding of the logs), even if I do nothing.
>>> It's even worse than I thought because when I tried to shutdown, the
>>> machine wouldn't shutdown because it claimed
>>> the "File manager" was still running (although it was not visible on
>>> screen); so I had to kill that before I could shutdown (properly).
>>>
>>> In Fedora 12 I had a similar user experience (nautilus did show up
>>> without showing any contents and it was hanging). I had enabled
>>> tracing and it seems to be logged to /var/log/messages. I got this
>>> output in fedora:
>>> Jan 25 20:48:38 localhost kernel: NFS reply statfs: -5
>>> Jan 25 20:48:38 localhost kernel: nfs_statfs: statfs error = 5
>>> Jan 25 20:48:38 localhost kernel: NFS call  fsstat
>>> Jan 25 20:49:14 localhost kernel: nfs: server 192.168.1.130 not
>>> responding, timed out
>>> Jan 25 20:49:14 localhost kernel: NFS reply getattr: -5
>>> Jan 25 20:49:14 localhost kernel: nfs_revalidate_inode: (0:14/74386)
>>> getattr failed, error=-5
>>> Jan 25 20:49:25 localhost kernel: NFS: revalidating (0:14/74386)
>>> Jan 25 20:49:25 localhost kernel: NFS call  getattr
>>> Jan 25 20:50:14 localhost kernel: nfs: server 192.168.1.130 not
>>> responding, timed out
>>> Jan 25 20:50:14 localhost kernel: NFS reply access: -5
>>> Jan 25 20:50:14 localhost kernel: NFS: permission(0:14/74386),  
>>> mask=0x1,
>>> res=-5
>>> Jan 25 20:50:14 localhost kernel: NFS call  access
>>> Jan 25 20:51:14 localhost kernel: nfs: server 192.168.1.130 not
>>> responding, timed out
>>> Jan 25 20:51:14 localhost kernel: NFS reply statfs: -5
>>> Jan 25 20:51:14 localhost kernel: nfs_statfs: statfs error = 5
>>> Jan 25 20:51:14 localhost kernel: NFS call  fsstat
>>> Most of the trace is repeating in set intervals as well, there is no
>>> flooding of the logs...
>>> Fedora would not shutdown normally either
>>
>> This verifies that your client is attempting to access the NFS  
>> server, but
>> doesn't tell us which file it's attempting to access.  Essentially  
>> the EIO
>> means "failed to connect".
>>
>> Maybe try an strace of the nautilus process next?
>>
>>> On Mon, Jan 25, 2010 at 5:48 PM, Chuck Lever  
>>> <chuck.lever@oracle.com>
>>> wrote:
>>>>
>>>> On Jan 24, 2010, at 7:09 PM, Whoop Whouzer wrote:
>>>>>
>>>>> I did some network traces and there is nothing strange happening  
>>>>> as
>>>>> far as I can tell. I shut down the server (some network traffic
>>>>> occurred as is to be expected). It got quiet again, I launched
>>>>> nautilus, it got stuck without displaying anything and there was  
>>>>> no
>>>>> real network activity except 3 broadcasts using the ARP protocol
>>>>> asking where the server was (could be just coincidence).
>>>>
>>>> That sounds like the client does want to reconnect with the server.
>>>>
>>>> You could try enabling debug tracing on your client (sudo  
>>>> rpcdebug -m nfs
>>>> -s
>>>> all) after shutting down your server, then try to start  
>>>> nautilus.  The
>>>> kernel log would then contain NFS-related messages that might  
>>>> indicate
>>>> where
>>>> to look next.
>>>>
>>>>> Closing
>>>>> nautilus and launching it again will let it hang again but I see  
>>>>> no
>>>>> additional network traffic. After a while nautilus will display  
>>>>> the
>>>>> contents of the folder without any network traffic.
>>>>>
>>>>> On Sun, Jan 24, 2010 at 10:34 PM, Muntz, Daniel <Dan.Muntz@netapp.com 
>>>>> >
>>>>> wrote:
>>>>>>
>>>>>> Perhaps something in your $PATH is in the NFS mount?  Do a  
>>>>>> network
>>>>>> trace
>>>>>> and maybe you can see if, in fact, there are actually NFS  
>>>>>> operations
>>>>>> being
>>>>>> attempted that you weren't expecting.  Then try to figure out  
>>>>>> why.
>>>>>>
>>>>>>  -Dan
>>>>>>
>>>>>>> -----Original Message-----
>>>>>>> From: Whoop Whouzer [mailto:tiredandnumb@gmail.com]
>>>>>>> Sent: Saturday, January 23, 2010 8:28 AM
>>>>>>> To: Peter Chacko
>>>>>>> Cc: linux-nfs@vger.kernel.org
>>>>>>> Subject: Re: nfs client performance while server is down
>>>>>>>
>>>>>>> I don't remember all the different set-ups I tried it on, but  
>>>>>>> I just
>>>>>>> confirmed this with the following combinations:
>>>>>>>
>>>>>>> ubuntu server 10.04 (alpha 2) --> ubuntu desktop 9.10, ubuntu  
>>>>>>> desktop
>>>>>>> 10.04 (alpha 2), fedora 12
>>>>>>> ubuntu server 9.10 --> ubuntu desktop 9.10, ubuntu desktop 10.04
>>>>>>> (alpha 2), fedora 12
>>>>>>>
>>>>>>> I'll be happy to test it on another client machine (distro) even
>>>>>>> another server (although it would require a little more time)
>>>>>>>
>>>>>>> Here are some examples on the bugreports I noticed and how  
>>>>>>> they do not
>>>>>>> seem to get solved:
>>>>>>> https://bugzilla.redhat.com/show_bug.cgi?id=175283
>>>>>>> https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/164120
>>>>>>>
>>>>>>> regards,
>>>>>>> Whoop
>>>>>>>
>>>>>>> On Sat, Jan 23, 2010 at 4:57 PM, Peter Chacko
>>>>>>> <peterchacko35@gmail.com> wrote:
>>>>>>>>
>>>>>>>> Which client OS you observed this behavior ?  This has  
>>>>>>>> nothing to do
>>>>>>>> NFS design, and its purely stateless...Its upto the client OS
>>>>>>>> implementation about aspects like how to deal with local
>>>>>>>
>>>>>>> IO, when NFS
>>>>>>>>
>>>>>>>> share gets  disconnected..
>>>>>>>>
>>>>>>>> May be a VFS bug on the local OS you found this problem ..
>>>>>>>>
>>>>>>>> thanks
>>>>>>>>
>>>>>>>> On Sat, Jan 23, 2010 at 9:15 PM, Whoop Whouzer
>>>>>>>
>>>>>>> <tiredandnumb@gmail.com> wrote:
>>>>>>>>>
>>>>>>>>> Howdy,
>>>>>>>>>
>>>>>>>>> I was wondering why nfs is designed in such a way that the
>>>>>>>
>>>>>>> performance
>>>>>>>>>
>>>>>>>>> of an nfs client machine gets very bad when the nfs server
>>>>>>>
>>>>>>> is offline?
>>>>>>>>>
>>>>>>>>> This is even the case with a soft mount (either via mount
>>>>>>>
>>>>>>> or fstab).
>>>>>>>>>
>>>>>>>>> Just about every application that requires disk access (not  
>>>>>>>>> talking
>>>>>>>>> about nfs share acces) gets really slow to unresponsive.
>>>>>>>
>>>>>>> For instance
>>>>>>>>>
>>>>>>>>> nautilus becomes unresponsive when displaying the contents  
>>>>>>>>> of any
>>>>>>>>> folder on the local disk,
>>>>>>>>> playing movie files (stored on local disk) let totem or
>>>>>>>
>>>>>>> vlc get stuck
>>>>>>>>>
>>>>>>>>> on set intervals, even the terminal becomes unresponsive at  
>>>>>>>>> times.
>>>>>>>>>
>>>>>>>>> I could understand that these problems would occur while
>>>>>>>
>>>>>>> accessing the
>>>>>>>>>
>>>>>>>>> nfs share directoiourry while the server is offline, but
>>>>>>>
>>>>>>> why for totally
>>>>>>>>>
>>>>>>>>> unrelated directories?
>>>>>>>>>
>>>>>>>>> I have experienced this behaviour on various distro's, and
>>>>>>>
>>>>>>> also found
>>>>>>>>>
>>>>>>>>> various bug reports on this issue, they don't seem to get  
>>>>>>>>> solved as
>>>>>>>>> this is viewed as nfs design.
>>>>>>>>> I see this as a flaw because clients are totally dependent  
>>>>>>>>> on the
>>>>>>>>> server. This would be less of a deal if the entire home  
>>>>>>>>> directory
>>>>>>>>> would be stored on nfs (although I even think some sort of
>>>>>>>>> synchronisation technology could and should be implemented  
>>>>>>>>> in this
>>>>>>>>> case). It is a bit odd that (technically) one machine  
>>>>>>>>> serving some
>>>>>>>>> "useless" files to a non-trivial directory on client
>>>>>>>
>>>>>>> machines can take
>>>>>>>>>
>>>>>>>>> down these client machines.
>>>>>>>>>
>>>>>>>>> For me the preferred functionality would be:
>>>>>>>>> *If an nfs server gets offline the client's nfs share becomes
>>>>>>>>> unaccessible, but local directories and applications (that  
>>>>>>>>> only
>>>>>>>>> require local disk access) stay responsive.
>>>>>>>>> *If an nfs server gets online (after being offline while the  
>>>>>>>>> client
>>>>>>>>> has not been restarted) the nfs share becomes reconnected.
>>>>>>>>>
>>>>>>>>> regards,
>>>>>>>>> Whoop
>>>>>>>>> --
>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe
>>>>>>>
>>>>>>> linux-nfs" in
>>>>>>>>>
>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>
>>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe
>>>>>>> linux-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>
>>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>>>> nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>> --
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>
>>>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>
> <stracesdiff.log>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



