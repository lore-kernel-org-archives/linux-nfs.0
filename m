From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Wed, 24 Nov 2004 19:45:25 +0100
Message-ID: <41A4D6C5.2060902@int-evry.fr>
References: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com> <41A3AFC4.6080404@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX297-0003dI-3I
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 10:45:41 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CX293-00032m-P1
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 10:45:40 -0800
In-Reply-To: <41A3AFC4.6080404@int-evry.fr>
Sender: nfs-admin@lists.sourceforge.net
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

Good advice :-), externalizing the journal from my FS on the AX100 SP to 
an internal SCSI disk on the NFS server is very good in terms of 
performances, now it take 1,5 minutes instead of 12m to unter httpd 
archive !

Journal on a 16 Mo partition  , export sync, mount async
[root@arvouin /mnt/cobra3extjournaldata16/Nfs-test16]
$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    1m35.097s
user    0m0.872s
sys     0m2.409s

However now the tar extraction goes very fast but stops 1 or 2  or  and 
restart fast -> there are some hangs. Here with a 16MB journal I got 15 
hangs of 1-2 seconds, with a 128 MB I get only 3 hangs but they last 4or 
5 seconds. I checked at a momment of an hang on the nfs server with 
iostat, and disk utilisation goes from a few % to  316 % in the exemple 
below (for 128 MB journal withing the 4 seconds hangs it goes to 4700 % !)
Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/emcpowerl2
             0.00 150.67 97.33 224.00  768.00 3018.67   384.00  
1509.33    11.78    33.33   19.79   9.83 316.00

Maybe it hangs because the journal commits on the SP ! ?

Well, finally, is this safer in terms of performances to externalize 
journal than using async export ?
And is it possible to externalize a journal on an already existing ext3 
FS or do we need to reformat it ?

Thanks.

jehan procaccia wrote:

> Lever, Charles wrote:
>
>>
>> btw, it is fairly well understood that RAID-5 and NFS servers don't mix
>> well.  RAID-5's weakest point is that it doesn't handle small random
>> writes very well, and that's exactly what is required of it when
>> handling NFS traffic that consists mostly of metadata changes (file
>> creates, deletes, and so on).  neil explained clearly how to make the
>> best use of a RAID-5 with NFS: do your local file system journaling
>> somewhere else.
>>  
>>
> No, not yet, but  if it is safer and increase performances maybe I 
> should do it !
>
> Perhaps it's not the place to talk about ext3 here, but if someone on 
> the list did already put their journal on a separate device, please 
> confirm me those points:
> From what I read on man mkefs for ext3 FS I can create a journal on a 
> separate FS :
> mke2fs -O journal_dev external-journal
> creates the journal FS, on which device ? -> internal scsi drive of my 
> server or better placed on the dell/EMC SP ?
>
> mke2fs -J device=/dev/external-journal /dev/emcpower
> Format the FS and use the external journal just create above, but what 
> is the recommended size of the external journal ?  when journal is 
> internal it is said  the size of the journal must be at least 1024 
> filesystem blocks
> (in my case blocks a 4K size) so journal is at least 4 Mb, but should 
> it be bigger ?
>
> Finally, can I "externalize" an already internal journal from 
> production FS  (convert journal from inside to outside without 
> reformating the FS ) ?
>
> thanks.
>
>
>> when trying your workload locally on the NFS server, realize that there
>> are some optimizations that local file systems make, like caching and
>> coalescing metadata updates, that the NFS protocol does not allow.  this
>> affects especially workloads with lots of metadata change operations,
>> because the NFS protocol requires each metadata update to reside on
>> permanent storage before the NFS server replies to the client,
>> effectively serializing the workload with storage activity.
>>  
>>
>
>
>
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now. 
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
