From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: lock recovery problems after notification
Date: Tue, 7 Sep 2004 06:26:46 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040907132646.7823.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4fzp-0003Ru-9z
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 06:26:53 -0700
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1C4fzo-0005aC-NU
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 06:26:53 -0700
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

Hi,
    I am using suse 9.0 on cluster machines 
    (runnnig nfs servers) and on client machine.
    I am also using virtual ip so that nfsserver
    is transparently failed over to other machine.
    
    when nfs server fails over and sm-notify 
    notifies the client , client does not reclaim 
    locks  , reason being that nfsserver sends 
    notification using its base ip address and not 
    virtual ip
    
    Client does not find this base ip in its monitored

    host list(as it access nfs server using virtual
ip)
    
    This works on Redhat systems as rpc.statd has -n 
    option using which statd on server always 
    communicate with client using virtual ip
    (rpc.statd -n <virtual ip>)

    Also let me know if rpc.statd is going to be part 
    of Suse later or is sm-notify going to be modified

    to give full functionality of  rpc.statd

    Any suggestions would be appreciated
    Thanks,
    kiran


		
_______________________________
Do you Yahoo!?
Win 1 of 4,000 free domain names from Yahoo! Enter now.
http://promotions.yahoo.com/goldrush


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
