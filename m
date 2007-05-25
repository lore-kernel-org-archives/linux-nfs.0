From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Subject: mount blocking port for mountd
Date: Fri, 25 May 2007 13:54:49 +0200
Message-ID: <4656CE89.2060007@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrYk1-0003bP-UH
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 05:17:57 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrYk3-000808-9B
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 05:18:00 -0700
Received: from internaldeliver.acheron.ifi.lmu.de (localhost [127.0.0.1])
	by acheron.ifi.lmu.de (Postfix) with ESMTP id 57EB743667
	for <nfs@lists.sourceforge.net>; Fri, 25 May 2007 13:54:49 +0200 (CEST)
Received: from [141.84.1.30] (galois.bio.ifi.lmu.de [141.84.1.30])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by acheron.ifi.lmu.de (Postfix) with ESMTP id 4206A435F7
	for <nfs@lists.sourceforge.net>; Fri, 25 May 2007 13:54:49 +0200 (CEST)
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

Hi,

during boot we mount some fs via NFS on our local NFS-server. The remote 
NFS-server is far away and the connection sometimes hangs. To avoid the 
local NFS server hanging too long, waiting for the remote NFS, we mount
in background with 

mount -at nfs,nfs4 & sleep 8

Now it happens that when the remote NFS server is a bit slow, our local
NFS server can't start:
May 25 12:25:48 backus rpc.mountd: Could not bind name to socket: Address already in use

That's because we define MOUNTD_PORT=700 due to some firewall reasons.
But port 700 is still blocked by some mount process:

backus /root# netstat -a -n |grep 700
tcp        0      0 <local nfs server ip:700          <remote nfs server ip>:735       TIME_WAIT   

We mount about 30 directories from the remote server and the local server
seems to use a bunch of ports initially.

Can I avoid the "mount" process using port 700? Like telling it to use only
port > 700 etc.?

This is SLES 10 btw, kernel 2.6.16.

cu,
Frank



-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
