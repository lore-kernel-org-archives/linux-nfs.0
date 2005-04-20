From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: order of starting nfsd and mountd
Date: Wed, 20 Apr 2005 07:51:10 -0700 (PDT)
Message-ID: <20050420145111.90658.qmail@web51610.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOGXv-0004nA-2w
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 07:51:19 -0700
Received: from web51610.mail.yahoo.com ([206.190.38.215])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DOGXt-0007wH-Cr
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 07:51:18 -0700
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
     I tried starting rpc.mountd before nfsd and
     when nfs restarts , client gets nfs stale handle 
     error(RHEL4 GA 2.6.9-5.ELsmp).
     If mountd is started after nfsd , everything
works
     find.
     Why is this dependency or ordering ?

regards,
 --kiran

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
