From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: file :"/var/lib/nfs/rmtab"
Date: Wed, 2 Feb 2005 22:08:44 -0800 (PST)
Message-ID: <20050203060844.3898.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwaAf-0004xb-Eu
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 22:08:53 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CwaAc-0006bD-FS
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 22:08:53 -0800
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
       In mountd man page , it written that
       rmtab is ornamental and client can contiune
       to use filesystem even after calling umount
       for that filesystem.

       Is there any real use of this rmtab file ?
       Does mountd use this file to know the
       clients having access to filesystem ?
       If yes , isn,t filehandle supplied by 
       client enough to prove that client has access
       to filesystem. ?

thanks,
 --kiran




		
__________________________________ 
Do you Yahoo!? 
Meet the all-new My Yahoo! - Try it today! 
http://my.yahoo.com 
 



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
