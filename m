From: Phy Prabab <phyprabab@yahoo.com>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Fri, 28 May 2004 09:57:25 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040528165725.99256.qmail@web90008.mail.scd.yahoo.com>
References: <20040528135515.GG5657@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.linux.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTkfk-0002gq-J4
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 09:57:32 -0700
Received: from web90008.mail.scd.yahoo.com ([66.218.94.66])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BTkfi-00019r-L0
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 09:57:30 -0700
To: Olaf Kirch <okir@suse.de>, Harald Hannelius <harald+nfs@arcada.fi>
In-Reply-To: <20040528135515.GG5657@suse.de>
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

Hello,

I have been watching this thread with interest.  I
have a 2.6.6-mm5 kernel NFS server in production and
have noticed some significant slow down to that server
(in comparison to an old crusty 2.4.22 kernel and
NetApp).  I too would like to understand the issue
here so I have run iozone as indicated to give another
point of interest.  Note, that during one of the tests
(nfsv2,udp,8192, the server crawled to a halt, load
sky rocketed to 30 with zero load (100% available
reported by top), at this point the server refused
access via ssh/rsh and refused to export any volumes,
but ping-able.  At terminal, everything behavied
normal.

Prior to the lock up, here are the numbers I was
getting:

Client 2.6.6-m5

2.6.6-mm5:

        File size set to 1048576 KB
        Record Size 1024 KB
        SYNC Mode. 
        Command line used:
/var/tmp/iozone/src/current/iozone -s 1g -r 1m -o -i 0
        Output is in Kbytes/sec
        Time Resolution = 0.000001 seconds.
        Processor cache size set to 1024 Kbytes.
        Processor cache line size set to 32 bytes.
        File stride size set to 17 * record size.
                                                      
     
UDP, NFSv2, sync, r/w 8192
         1048576    1024   39889   38745              
                                                      
                      
UDP, NFSv3, sync, r/w 32768
         1048576    1024   12226   10749
TCP, NFSv3, sync, r/w 32768
         1048576    1024   11909   12208              
                                                      
                      

2.4.22
UDP, NFSv3, sync, r/w 32768
         1048576    1024   11259   10761
UDP, NFSv3, sync, r/w 8192
         1048576    1024    6136    6266              
                                                      
        


I cc'ed the linux-kernel mailing list as well.

Cheers,
Phy


--- Olaf Kirch <okir@suse.de> wrote:
> [2.6 over loopback nfs]
> > real    6m21.086s
> > user    0m1.712s
> > sys     0m5.454s
> 
> [2.4 over loopback nfs]
> > real    1m11.875s
> > user    0m1.730s
> > sys     0m7.730s
> 
> This roughly matches some performance issues I've
> been seeing on a 2.6.5
> kernel. Are you using reiser or ext3?
> 
> In general, dd to a local file is much different
> from what NFS does,
> because nfsd flushes data to disk.
> 
> The NFS client will usually issue a COMMIT call
> roughly every 1 Meg,
> so the following should mimic the behavior of nfsd a
> little better,
> when run on your file system locally
> 
> 	iozone -s 1g -r 1m -o -i 0
> 
> Higher numbers indicate better performance.
> 
> Could you run this on 2.4 and 2.6, please?
> 
> Olaf
> -- 
> Olaf Kirch     |  The Hardware Gods hate me.
> okir@suse.de   |
> ---------------+ 
> 
> 
>
-------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the
> market... Oracle 10g. 
> Take an Oracle 10g class now, and we'll give you the
> exam FREE.
>
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



	
		
__________________________________
Do you Yahoo!?
Friends.  Fun.  Try the all-new Yahoo! Messenger.
http://messenger.yahoo.com/ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
