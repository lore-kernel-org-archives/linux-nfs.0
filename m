From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: lockd recovery failure
Date: Wed, 8 Dec 2004 07:17:48 -0800 (PST)
Message-ID: <20041208151749.82833.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc3Zj-0006Sg-Ch
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 07:17:55 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1Cc3Zi-0001SM-Q9
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 07:17:55 -0800
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
    I have RHEL 4.0 beta2 installed on my machines.
    NFS server run on these machines.
    NFS client runs on machine with sles9 sp1 beta3 
    installed.

    I want to achieve NFS lock failover on cluster
    For this , i have a floating ip which floats
    on cluster machines

    rpc.statd is runnnig with commandline option -n
    i:e rpc.statd -n  <virtual ip>

    But when NFS server fails over to other
    machine  , client gets SM_NOTIFY message but
    it does not reclaim locks.

    In var/log/message following is the message 

    statd :NOTIFY called
    lockd: nlm_host_rebooted(base ip of server)

    So the reason for lock recovery is that
    notification is given to client using base ip
    of server and not the ip specified with -n 
    option.

    However , when I have above mentioned redhat
    machines and RHEL 3 Update2 client everthing
    works well(sm_notify recevied with ip in 
    -n option)
    Also , if I use sles9 sp1 beta3 server and
    sles9 sp1 beta3 client everthing works

    So , I am not able to figure out the 
    component which has problem.
    Is it sles9 sp1 beta3 client or RHEL 4.0
    Beta2 NFS server

thanks,
  kiran   
    

   
    


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - now with 250MB free storage. Learn more.
http://info.mail.yahoo.com/mail_250


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
