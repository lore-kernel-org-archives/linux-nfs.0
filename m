From: "ALLEN, David" <David.ALLEN@eur.crowncork.com>
Subject: mount problem with Snap server
Date: Mon, 31 Jan 2005 11:22:50 -0000
Message-ID: <1DB025F33C6990409DA31A122F9AEBB80129A0BE@zzuk20.crowncork.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvZdt-0007gS-PU
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 03:22:53 -0800
Received: from relay1.bt.net ([194.72.6.100])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CvZdt-0005EW-0B
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 03:22:53 -0800
Received: from mailhost.eur.crowncork.com ([213.120.71.21] helo=a699uk03.ccsextranet.com)
	by relay1.bt.net with smtp (Exim 3.36 #1)
	id 1CvZdq-00044a-00
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 11:22:50 +0000
Received: from a699uk07.crowncork.com ([6.99.137.20])
 by a699uk03.ccsextranet.com (SMSSMTP 4.0.5.66) with SMTP id M2005013111225007435
 for <nfs@lists.sourceforge.net>; Mon, 31 Jan 2005 11:22:50 GMT
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



> Hi,
> 
> I know this might seem at first slightly off topic, but my gut feeling is
> the problem we are experiencing is in some way related to NFS. We have a
> major problem using Samba to access NFS mounted directories. The directory
> in question is on a Snap server running 2.1.19 and version 3 NFS, and
> Samba is running on a new Sun V250 running Solaris 9.
> 
> The problems occur when trying to load a file which is on the NFS
> directory, which causes the samba process to crash. Another process starts
> automatically, crashes and so forth.
> 
> However, the exact same configuration, NFS mount, Samba version etc works
> fine on an old Sun Utlra 10, also running Solaris 9! Also, everything
> appears to work fine at the Unix level on both machines. It also worked
> fine before we upgraded the Snap server to the new Linux kernel. The old
> kernel was running version 2 NFS.
> 
I have tried setting the NFS version to V2, and also specifing proto=udp  on
the Sun v250 to no effect. 

> Thanks in advance for any help/suggestions/pointers. We are getting
> desperate! 
> 
> David
> 
> Log level 3:
> 


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
