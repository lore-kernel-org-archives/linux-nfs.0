From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: address for lockd recovery
Date: Tue, 25 Jan 2005 01:16:49 -0800 (PST)
Message-ID: <20050125091649.70886.qmail@web51605.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtMom-0007EY-9r
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 01:17:00 -0800
Received: from web51605.mail.yahoo.com ([206.190.38.210])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CtMok-0005L6-NY
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 01:17:00 -0800
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
     When i was checking lockd recovery , 
     i noted that clients after getting
     notification messages , use mon_id
     as destination address and not notication
     messages's source address as destination
     address.(as just a reply)

     Is there any issue in using notifcation
     messages's source address as destination
     address to reclaim lock. ?   
     If not , doing this may help clients to
     recover locks faster as mon_id which is
     generally virtual ip may come up later
     but notification messages's source address
     will definitely be up most of the time.

thanks,
--- kiran


		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - Get yours free! 
http://my.yahoo.com 
 



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
