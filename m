From: Edward Hibbert <EH@dataconnection.com>
Subject: Not responding errors - what is it doing?
Date: Thu, 12 Jun 2003 15:52:42 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFCD2C778CF1D611B5B400065B04D5C84A7525@KENTON>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp2.dataconnection.com ([192.91.191.8] helo=miles.dataconnection.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QTRX-0008Do-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 07:52:48 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Here's a rookie question.  I'm trying to track down the cause of some server
not responding errors against a SNAP Appliance filer.  It would be useful to
know how these are detected - does the NFS client do a test, or is it in
response to application-issued operations?  What's the timeout value before
it will log this?

Thanks,

Edward Hibbert
Internet Applications Group
Data Connection Ltd
Tel:	+44 131 662 1212		Fax:	+44 131 662 1345
Email:	eh@dataconnection.com	Web:	http://www.dataconnection.com




-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
