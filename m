From: Jan Bruvoll <jan@bruvoll.com>
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 13:00:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <410643C5.3040004@bruvoll.com>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407261905.40248.bernd-schubert@web.de> <41055FE5.3030206@bruvoll.com> <200407270006.08581.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS mailling list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpQd4-0002pL-5b
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 05:00:22 -0700
Received: from homer.brvl.com ([213.61.99.172])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BpQd3-00054e-DY
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 05:00:22 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407270006.08581.bernd-schubert@web.de>
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

Bernd Schubert wrote:

>>are you doing anything "interesting" underneath NFS, ie. what are you
>>storing your files on?
>>    
>>
>
>Its similar to your configuration ;)
>  
>

Good :-)

>>My set-up has about the same performance data, however my big problem is
>>that the server dies when I hook all my clients up... Raw throughput
>>    
>>
>
>Fortunately that doesn't seem to happen in our case.
>  
>

Let me clarify - the server doesn't quite die, however it slows down 
drastically, having a load of ~7 while 99% CPU idle. The clients clog 
up, and for instance trying to mount anything just times out. If I 
unmount the busy share from the clients, everything settles down again.

>>seemed ok, but when you started complaining about the speed, I started
>>thinking that my figures weren't all that great anymore.
>>    
>>
>
>At least its good to know that we are not alone. Well, I do know about the 
>performance decrease of sync-exports for a pretty long time, but I was never 
>sure if its not only a problem of our server (the previous one was a 
>PII-450).
>
>  
>
>>The set-up is a dual 3Ghz Xeon, 2Gb RAM, and a DRBD-mirrored partition
>>sitting on a 3Ware Escalade 7500 to 7200rpm disks. Kernel
>>    
>>
>
>Here its a dual opteron, 3GB RAM, adaptec 79xx PCI-X scsi, transtec scsi-ide 
>raid. Local disk i/o is over 70MB/s. The server is connected with GBit, the 
>clients only with 100MBit. Here are some performace numbers when the server 
>was still running 2.6.7:
>
>writing to /worka (async exported): 4 clients, all at full 11MB/s
>
>writing to /home, (sync,no_wdelay exported): 4 clients at 7MB/s
>
>(When I did the tests I was simply to lazy to test with more clients. Actually 
>I thought that 4 times 7 MB/s is more than sufficient for usual work).
>
>The /home partition is also mirrored via drbd to a failover server, /worka is 
>not mirrored (mirroring 1.7TB is not that easy as mirroring 200GB ;) ).
>
>So I really don't think that the server performance is the problem.
>  
>

I tried a little more performance number hunting:
 - NFS copy and write to same device - 3Mb/s sustained (500Mb file)
 - piozone direct write to RAID device - ~34-50Mb/s (depending on file size)
 - drbd network device - 933Mb/s

Nothing really wrong here I'd say - not blazingly quick, but surely 
nothing to explain why everything just stops when I hook up my 12 
clients to this set-up?

>>2.4.26-gentoo-r5, everything else newest version. The annoying thing is
>>that the server this new set-up is replacing is an old P3/650 that
>>easily copes with the load... :-\
>>    
>>
>
>Well, as I said, when I tested our old server with sync mounts, it had the 
>same problem. Are you sure that your old server did not export asynchronous?
>  
>

Doesn't seem so, no, the /etc/export is -extremely- simple:

/export client1(rw,no_root_squash)

Similarly, I'm not trying to be clever on the client side (/etc/fstab 
excerpt):

server:/export /export nfs rw,hard,intr 0 0

This set-up works wonderfully on the old 2.4.17 box, but grinds to a 
halt on the new ones :-(

Regards
Jan



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
