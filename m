From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: lockd grace period
Date: Tue, 1 Feb 2005 02:46:08 -0800 (PST)
Message-ID: <20050201104608.17913.qmail@web51608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, chetan@hp.com
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvvY0-0007QD-2h
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 02:46:16 -0800
Received: from web51608.mail.yahoo.com ([206.190.38.213])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CvvXy-0000hi-G1
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 02:46:15 -0800
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

Hi  , 
        I verified that suse NFS server enters
grace period whenever nfsd starts , irrespective
of whether lockd was already runnnig or not.
While Red Hat NFS server (RHEL 4 pre_rc2) does
not restart grace period of already running
lockd , even if nfsd restarts.

**Can anybody let me know what the standard behaviour
  should be. ??

What i think is that suse does it right by restarting
nfs grace period of already running lockd.
This is because machine acting as nfs server
can definitely act as nfs client of some other
machine(though rare but occurs).

Will nfs developers from Suse "also" like to comment
on this?

thanks,
-- kiran

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
