From: Eric Whiting <ewhiting@amis.com>
Subject: RPC request error message
Date: Wed, 24 Apr 2002 08:48:13 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CC6C5AD.3048F8D6@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170ODY-0007Ik-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 07:58:00 -0700
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Apr 24 06:16:08 windriver kernel: RPC request reserved 240 but used 244
Apr 24 06:17:58 windriver kernel: RPC request reserved 240 but used 244
Apr 24 06:17:58 windriver kernel: RPC request reserved 52 but used 56
Apr 24 06:34:35 windriver kernel: RPC request reserved 240 but used 244
Apr 24 06:34:35 windriver kernel: RPC request reserved 52 but used 56



I get about 50-200 of these messages each day. Kernel is 2.4.18. I see
this message in one of Neil's recent patches.

    +       /* Reset response buffer and release
    +        * the reservation.
    +        * But first, check that enough space was reserved
    +        * for the reply, otherwise we have a bug!*/
    +       
    +       if ((rqstp->rq_resbuf.len<2) >  rqstp->rq_reserved)
    +               printk(KERN_ERR "RPC request reserved %d but used
%d\n",
    +                      rqstp->rq_reserved,
    +                      rqstp->rq_resbuf.len<2);
    + 
    
Is anyone else seeing this?

eric

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
