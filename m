From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: nfs lock failover : problem in connection
Date: Wed, 18 Aug 2004 08:51:00 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040818155100.86349.qmail@web51610.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxSiS-0002UV-6R
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 08:51:08 -0700
Received: from web51610.mail.yahoo.com ([206.190.38.215])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.34)
	id 1BxSiP-0007JQ-Iq
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 08:51:08 -0700
To: nfs@lists.sourceforge.net
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

Hi , 
   i am facing problem when nfs server fails over to
other node on the cluster
   
    I have two node cluster and third node acts as
client.
    Two nodes in the cluster share lock information by
making link
    /var/lib/nfs on shared disk.Also filesystem to be
exported are
    present on other partition of same shared disk.
    I am using virtual ip as well using which client
access filesystem
    exported by nfs server
 
    Client mounts the exported filesystem. Then it
runs a small sample code
    which takes lock on file present on exported
filesystem , sleeps for some     time and releases it.
This works well
 
    1. when nfs is restarted on same node on which it
fails.
    2. when program acquires and relases lock and NFS
is killed on
        first node and started on other node. Client
is still able to access old
        filesystem without remouting it
 
       But  if following steps are followed , program
on client side hangs
 
        1. acquires lock on file present of exported
filesystem
        2. kill nfs on first cluster node before
client program releases the lock and start nfs on
second node
 
        Using tcpdump,netstat and debug messages
produced 
        by setting values in
/proc/sys/sunrpc/nfsd_debug... , i have 
        concluded  that program on   client tries to
connect to server after     
         server   sends SM_NOTIFY  message but
connection is never 
        established and hence program on client side
is not able to regain the lock
 
        tcpdump shows that sync packet is being sent
continuously to server but is not getting any reply
 
        Can anybody point out the problem ?????
        Awaiting the suggesstion
 
    thanks
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
