From: Jason Holmes <jholmes@psu.edu>
Subject: Re: NFS stops responding
Date: Fri, 01 Oct 2004 11:40:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <415D7A76.7000404@psu.edu>
References: <1096551562.2696.19.camel@douglas-furlong.firebox.com> <415C2F07.4030308@psu.edu> <415C5A33.50202@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CDPWC-00027P-FC
	for nfs@lists.sourceforge.net; Fri, 01 Oct 2004 08:40:24 -0700
Received: from vpn-19-8.aset.psu.edu ([146.186.19.8] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CDPWB-0001fq-As
	for nfs@lists.sourceforge.net; Fri, 01 Oct 2004 08:40:24 -0700
Received: from [127.0.0.1] (funkmachine.cac.psu.edu [127.0.0.1])
	by funkmachine.cac.psu.edu (Postfix) with ESMTP id 7B43B36B27
	for <nfs@lists.sourceforge.net>; Fri,  1 Oct 2004 11:40:38 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <415C5A33.50202@psu.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

FYI, I'm beginning to suspect that this is a problem more with the newer 
RedHat kernels than anything else.  I've only had one vanilla kernel NFS 
lockup since I moved the NFS servers to 2.6.8.1 (3 days) and that 
happened right after I did the move, so it could be coincidental.  Back 
when the servers ran RedHat kernels, the RedHat kernel clients never 
locked up whereas the vanilla clients did.  Yesterday I had 4 NFS 
lockups on the same machine running the RedHat 2.4.21-20.ELsmp kernel 
(the one that generated the trace below), but it hasn't locked up since 
I moved it to 2.6.8.1.  I guess I'll know for sure if my lockups don't 
come back for a week or so.

Thanks,

--
Jason Holmes

Jason Holmes wrote:
> Here's a 'sysrq-T' listing for a few hung processes.  Unfortunately, 
> this was on a 2.4.21-20.ELsmp RedHat kernel and not a vanilla kernel 
> (I'll send one of those along as soon as I can get one):
> 
> xauth         D 00000100e2d30370  1312  9600   9599 (NOTLB)
> 
> Call Trace: [<ffffffff80120d8a>]{io_schedule+42} 
> [<ffffffff801420ed>]{___wait_on_page+285}
>        [<ffffffff8014316a>]{do_generic_file_read+1258} 
> [<ffffffff80143770>]{file_read_actor+0}
>        [<ffffffff801438c5>]{generic_file_new_read+165} 
> [<ffffffffa02ec3a9>]{:nfs:nfs_file_read+217}
>        [<ffffffff8015dfd2>]{sys_read+178} 
> [<ffffffff80110177>]{system_call+119}
> 
> bash          D 00000100e2bef130   824  9614      1          9666  9583 
> (NOTLB)
> 
> Call Trace: [<ffffffff80120d8a>]{io_schedule+42} 
> [<ffffffff801420ed>]{___wait_on_page+285}
>        [<ffffffff8014316a>]{do_generic_file_read+1258} 
> [<ffffffff80143770>]{file_read_actor+0}
>        [<ffffffff801438c5>]{generic_file_new_read+165} 
> [<ffffffffa02ec3a9>]{:nfs:nfs_file_read+217}
>        [<ffffffff8015dfd2>]{sys_read+178} 
> [<ffffffff80110177>]{system_call+119}
> 
> bash          D 00000100db051e28     0  9666      1          9718  9614 
> (NOTLB)
> 
> Call Trace: [<ffffffff80120d8a>]{io_schedule+42} 
> [<ffffffff80142466>]{__lock_page+294}
>        [<ffffffff801430ca>]{do_generic_file_read+1098} 
> [<ffffffff80143770>]{file_read_actor+0}
>        [<ffffffff801438c5>]{generic_file_new_read+165} 
> [<ffffffffa02ec3a9>]{:nfs:nfs_file_read+217}
>        [<ffffffff8015dfd2>]{sys_read+178} 
> [<ffffffff80110177>]{system_call+119}
> 
> Thanks,
> 
> -- 
> Jason Holmes
> 
> Jason Holmes wrote:
> 
>> I have had similar problems with NFS recently and have yet to figure 
>> out a pattern.  They started around the 2.4.27 time frame, but that 
>> could just be coincidental.  I have 8 NFS servers and several hundred 
>> clients.  Every few days, one of the clients will start hanging 
>> connections to one of its mounts (all of the processes access that 
>> mount go into D state and never return - the machine has to be 
>> forcefully rebooted to get rid of them).  While one of the client 
>> machines are hanging on a mount, the other client machines are fine.  
>> Access to the other mounts are fine on the hanging machine.  The 
>> server is fine when this happens and I see no odd messages in the logs.
>>
>> The servers were originally running RedHat Enterprise 3 kernels - I 
>> have also tried 2.6.8.1 and have had the same problem.  Clients have 
>> been 2.4.27, 2.6.8.1, and the latest RedHat kernels.  The network is a 
>> simple private one and there is no packet loss.  I've tried both UDP 
>> and TCP v3 hard mounts.  Exports are synchronous.
>>
>> I'm currently hoping that one of my machines with sysrq enabled will 
>> hang to see if I can possibly get some information out of that that 
>> will shed some light on the situation.  I'd be happy to entertain any 
>> other debugging suggestions on this.  Unfortunately, I haven't been 
>> able to figure out how to force the problem to happen, so I'm at the 
>> mercy of waiting for it to just pop up.
>>
>> Thanks,
>>
>> -- 
>> Jason Holmes
>>
>> Douglas Furlong wrote:
>>
>>> Good morning all.
>>>
>>> Considering the exceedingly fast and speedy response I got yesterday
>>> with regards to my problem accessing edirectory.co.uk I thought I would
>>> try my luck with an NFS problem.
>>>
>>> All our unix systems at work have their home directory mounted via NFS
>>> to allow hot seating (not that they ever use it!).
>>>
>>> I have just recently upgraded to Fedora Core 2, running the most recent
>>> kernel.
>>>
>>> All the workstations are running Fedora Core 2, with the second from
>>> last kernel (due to CIFS/SMB problems in the latest one).
>>>
>>> Unfortunately there are two users who's connection to the NFS server is
>>> dropped and does not seem to want to reconnect. To date I have.
>>>
>>> 1) Replaced both of their PC's
>>> 2) Replaced switch
>>> 3) will replace network cables tomorrow
>>> 4) I have tried numerous version of the kernel including the testing
>>> kernel from rawhide.
>>> 5) Tried variations in the timeo=x value to see if that will help.
>>>
>>> These lockups vary in time between 30 minutes and 5 hours. Network
>>> connections are not affected by this lock up, I am able to ssh on to the
>>> box (that's how I collected the tcpdump data).
>>>
>>> I also have two windows PC's on this switch and things appear to be
>>> fine.
>>>
>>> I have 7 or 8 other systems running linux on the network and NFS
>>> communication is not affected.
>>>
>>> I have increased the number of servers on the NFS server from 8 to 16. I
>>> did this by editing /etc/init.d/nfs (don't think this is of any help).
>>>
>>> I took some tcpdump info on both the client and the server to try and
>>> see if I can work out what is going on. Initially it is not providing me
>>> with much information (but loads of data).
>>>
>>> I have attached two files, one from the client and one from the server.
>>> Main reason for attaching them is due to length of data. I had wanted to
>>> attach them as plain text to simplify access, but at 100k it's a bit too
>>> large.
>>> I didn't want to cut them down too much just in case I removed some
>>> pertinent information :(
>>
>>
>>
>>
>>
>> -------------------------------------------------------
>> This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
>> Use IT products in your business? Tell us what you think of them. Give us
>> Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out 
>> more
>> http://productguide.itmanagersjournal.com/guidepromo.tmpl
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>>
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
> Use IT products in your business? Tell us what you think of them. Give us
> Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
> http://productguide.itmanagersjournal.com/guidepromo.tmpl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
