From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 08:31:20 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040820153120.84456.qmail@web51603.mail.yahoo.com>
References: <4125EA9F.3040304@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByBMb-0001n4-K2
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 08:31:33 -0700
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1ByBMW-0001dI-BV
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 08:31:32 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <4125EA9F.3040304@bio.ifi.lmu.de>
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

hi,

   client apps survive only if nfs is restarted on
   on the same machine(running Suse 9).
   
   I had setup as follows:
        
     1. shared disk with two partitions.One partition 
        is mounted on /var/lib/nfs and other contains 
        the filesystem to be exported.

     2. I had two nodes in the cluster and had virtual

        (floating) ip through which client accesses
        the exported filesystem.

     3 .i had only one client accessing filesystem 
         which server had exported

     I have written program which opens a file from 
      filesystem, locks it , sleeps for 10 seconds and

     then  unlocks it.

    I followed steps and found that client app hangs.

       1.on client node i stared the program 
       2.Then when the lock was acquired , i killed
         nfsd running on the server (on node one).
       3.when nfsd comes up on second node in the 
         cluster client is not able to communicate
         with server and hangs for long duration
         (this at last gives permission denied error
          Before this error is given , i execute
          step4 )
          
       4. If after sometime nfsd is again brought 
          up  on first   , client program communicates

          with  nfs server and releases lock.
    
       There is no problem with floating ip
       Also both machines in cluster have exactly
       same configuration and minimal security

       Using netstat and tcpdump dump , i found that
       floating ip works well but client is not
       able to communicate with new nfs server(present
       on second node). Netstat shows that client 
       continuously send SYN packet to nfs server but 
       gets no ACK packet.

       I have been debugging these for past 2 days but
       found no solution


thanks,
    kiran
 


       





   



	
		
__________________________________
Do you Yahoo!?
New and Improved Yahoo! Mail - 100MB free storage!
http://promotions.yahoo.com/new_mail 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
