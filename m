From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: message :  NFS: problem in nfs4 mounting
Date: Sat, 5 Mar 2005 04:31:39 -0800 (PST)
Message-ID: <20050305123139.25306.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7YRf-0003KF-4A
	for nfs@lists.sourceforge.net; Sat, 05 Mar 2005 04:31:47 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D7YRd-0008Pw-6y
	for nfs@lists.sourceforge.net; Sat, 05 Mar 2005 04:31:47 -0800
To: nfs@lists.sourceforge.net
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

Hi , 
     (RHEL4 GA on both client and server machines)
      I started all the nfs daemons including
     rpc.gssd and rpc.idmapd and exported /share
     to client.I also started rpc.gssd and 
     rpc.idmapd on client

     Server exports /share to world.
     when client tried to mount /share using

     mount -t nfs4  <server>:/share /client_mnt_point
     Following message occur in log.
      
     NFS :mount path /share does not exist.  
     NFS :suggestion : try mounting '/' instead
     
     Then i tried

      mount -t nfs4  <server>:/ /client_mnt_point

     and surprisingly it worked.
 
     When i had exported /share (it exists) how did
     client mount / and why did it give error when i
     tried mounting /share.
     
     Pleae let me know ?

thanks
 -- kiran




__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
