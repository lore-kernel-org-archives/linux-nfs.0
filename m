From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Tue, 23 Nov 2004 22:46:44 +0100
Message-ID: <41A3AFC4.6080404@int-evry.fr>
References: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWiV7-0002ei-Hk
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 13:47:05 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWiV5-000068-GV
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 13:47:05 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:

>>This is what I expect in term of performances . I will continue my 
>>requests on the DEll/EMC hotline , but maybe the security of 
>>that AX100 
>>storage Processor (raid5, spare disk, double fiber attachement, UPS) 
>>allows me to use async export mode in such a case ?
>>    
>>
>
>the "async" export option changes the behavior of the NFS server
>daemons, not of the underlying local file system or storage subsystem.
>the problem is that changes made by clients will remain in your NFS
>server's memory and not get flushed onto permanent storage.
>
>so, i really don't think the storage subsystem will have any effect on
>the safety of your data before the data reaches permanent storage.  as
>someone else pointed out earlier, the solution is to use battery-backed
>main memory when using "async" (prestoserve for solaris?).
>
>as trond said, if your users and backup facilities can tolerate the loss
>of data during a crash, then it is perfectly fine to use "async."  most
>don't, however.
>
>btw, it is fairly well understood that RAID-5 and NFS servers don't mix
>well.  RAID-5's weakest point is that it doesn't handle small random
>writes very well, and that's exactly what is required of it when
>handling NFS traffic that consists mostly of metadata changes (file
>creates, deletes, and so on).  neil explained clearly how to make the
>best use of a RAID-5 with NFS: do your local file system journaling
>somewhere else.
>  
>
No, not yet, but  if it is safer and increase performances maybe I 
should do it !

Perhaps it's not the place to talk about ext3 here, but if someone on 
the list did already put their journal on a separate device, please 
confirm me those points:
 From what I read on man mkefs for ext3 FS I can create a journal on a 
separate FS :
mke2fs -O journal_dev external-journal
creates the journal FS, on which device ? -> internal scsi drive of my 
server or better placed on the dell/EMC SP ?

mke2fs -J device=/dev/external-journal /dev/emcpower
Format the FS and use the external journal just create above, but what is the recommended size of the 
external journal ?  when journal is internal it is said  the size of the journal must be at least 1024 filesystem blocks
(in my case blocks a 4K size) so journal is at least 4 Mb, but should it be bigger ?

Finally, can I "externalize" an already internal journal from production FS  (convert journal from inside to outside without reformating the FS ) ?

thanks.


>when trying your workload locally on the NFS server, realize that there
>are some optimizations that local file systems make, like caching and
>coalescing metadata updates, that the NFS protocol does not allow.  this
>affects especially workloads with lots of metadata change operations,
>because the NFS protocol requires each metadata update to reside on
>permanent storage before the NFS server replies to the client,
>effectively serializing the workload with storage activity.
>  
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
