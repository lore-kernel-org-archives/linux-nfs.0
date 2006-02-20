From: Daniel Bramkamp <bramkamp@team-datentechnik.de>
Subject: Re: Permission denied
Date: Mon, 20 Feb 2006 16:43:22 +0100
Message-ID: <20060220164322.hv8kw08k08gk00kc@linux-smb.molly>
References: <20060207123448.pqv165xvwosgk0g8@linux-smb.molly>
	<20060220112535.GA10567@janus>
	<20060220131637.iqam5s8yb4o8co44@linux-smb.molly>
	<1140445899.7863.16.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-15;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBDCG-0004ji-Ui
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 07:43:32 -0800
Received: from natsluvver.rzone.de ([81.169.145.176])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FBDCF-0001P9-CJ
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 07:43:33 -0800
Received: from linux-smb.molly ([85.8.92.16])
	by post.webmailer.de (8.13.1/8.13.1) with ESMTP id k1KFhMnD011125
	for <nfs@lists.sourceforge.net>; Mon, 20 Feb 2006 16:43:22 +0100 (MET)
Received: from localhost (localhost [127.0.0.1])
	by linux-smb.molly (Postfix) with ESMTP id B4AE445973
	for <nfs@lists.sourceforge.net>; Mon, 20 Feb 2006 16:43:23 +0100 (CET)
Received: from linux-smb.molly ([127.0.0.1])
 by localhost (linux-smb.molly [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 05881-18 for <nfs@lists.sourceforge.net>;
 Mon, 20 Feb 2006 16:43:22 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <1140445899.7863.16.camel@lade.trondhjem.org>
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

Quoting Trond Myklebust <trond.myklebust@fys.uio.no>:


> You have to look at the client machine too.

yeah, the client in this case is a terminal server.

> Is the user still limited to 13 groups on the client, and do the
> numerical uid/gid values match on the client and server?

Since I use LDAP to store user accounts the uid and gid is the same on 
all servers. The user is not a member of any local group on any server 
either so the total number of groups the particular user is in is 13 on 
all servers. I just double checked that.

-- 
Daniel Bramkamp

team! datentechnik GmbH & Co.KG
Werner von Siemens Stra=DFe 12a
49124 Georgsmarienh=FCtte
Tel.: 05401-8226-0
Fax : 05401-8226-20
eMail: bramkamp@team-datentechnik.de


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
