From: LE PENSE Tangui <tangui.lepense@free.fr>
Subject: NFS reachable only on the local network
Date: Tue, 07 Aug 2007 21:24:13 +0200
Message-ID: <1186514653.6626.4.camel@deus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIUf9-0002xS-3O
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 12:24:15 -0700
Received: from smtp2-g19.free.fr ([212.27.42.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIUfB-0008Sf-T1
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 12:24:19 -0700
Received: from smtp2-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp2-g19.free.fr (Postfix) with ESMTP id 8AAB098FA8
	for <nfs@lists.sourceforge.net>; Tue,  7 Aug 2007 21:24:15 +0200 (CEST)
Received: from [192.168.0.3] (lnr56-1-82-246-48-65.fbx.proxad.net
	[82.246.48.65])
	by smtp2-g19.free.fr (Postfix) with ESMTP id 4DBAD98F6F
	for <nfs@lists.sourceforge.net>; Tue,  7 Aug 2007 21:24:15 +0200 (CEST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,

I apologize if this is not the good place to ask this king of question,
but I did not find any answer elsewhere.

I'm trying to share a directory with everybody on the local network I
connect myself, but I don't know how to do.

I tried by this way :
/multimedia *.local(ro)
or
/multimedia local(ro)
or again replacing local by localdomain

but the server's answer is always the same : access denied.

This would be very useful, cause sharing a dir by such a way would be
very easy with zeroconf.

Thank you in advance,

LE PENSE Tangui


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
