From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: lockd grace period
Date: Sun, 30 Jan 2005 23:41:27 -0800 (PST)
Message-ID: <20050131074127.32205.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvWBi-0004Bt-Op
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 23:41:34 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CvWBh-0000px-3I
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 23:41:34 -0800
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
        lockd is used by both nfs and autofs
if there are 2 machines runnnig 2.6 kernel
(Red Hat) .autofs and nfs both are running
on system1.When nfs is failed over to system2
, all daemons start on system2 , but
lockd on system1 is still alive as it is required
by autofs "client"(this machine has automounted
filesystem from some other machine).After say 5
minutes , if nfs
is failed over to system1 , lockd recovery
gives some problem.statd notifies client , 
but when client tries to reclaim lock , 
LOCK routine returns "unknown error"(30000).
Is is because  , lockd was runnnig since long
time on system1 and hence its grace period was over.

But I dont face same problem of sles9 sp1.
What is the expected behaviour.?
Is it that whenever nfsd starts  , lockd should enter
grace period ?
or
Is is that lockd should enter grace period only when
it restarts without caring for nfs.?

--thanks,
   kiran



	
		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - You care about security. So do we. 
http://promotions.yahoo.com/new_mail


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
