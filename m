From: Jeroen <jwilke@baselogistics.nl>
Subject: invalid argument when creating a file on an nfs share
Date: Tue, 23 Oct 2007 12:17:22 +0200
Message-ID: <ffkhif$h1c$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkHBA-0006en-N8
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 03:40:10 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IkHBE-0006pc-Dw
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 03:40:14 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1IkHB4-0004J4-Fe
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 10:40:02 +0000
Received: from d594eedd.static.dsl.concepts.nl ([213.148.238.221])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Oct 2007 10:40:02 +0000
Received: from jwilke by d594eedd.static.dsl.concepts.nl with local (Gmexim
	0.1 (Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Oct 2007 10:40:02 +0000
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

Whenever I try saving a file to a mounted nfs share I get the following 
error :

/mnt/home/user$ touch bla
touch: setting times of `bla': Invalid argument

it does create the file bla in the specified location but I am unsure as 
to what is causing this error.

users and groups on the client are "shared" via pam_ldap

/etc/exports on the server:

/home           192.168.0.8(rw,sync,map_identity,no_root_squash)


/etc/fstab on client:

192.168.0.12:/home/ /mnt/home nfs auto,rw 0 0

client OS is debian Etch,

Server is running debian unstable  nfs-user-server :Universal NFS Server 
2.2beta47

Regards

Jeroen




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
