From: "C.G." <skylendar@yahoo.com>
Subject: congratulations and request
Date: Thu, 8 Feb 2007 08:44:32 -0800 (PST)
Message-ID: <565874.47740.qm@web34206.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFCOC-0001Jk-E5
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 08:44:52 -0800
Received: from web34206.mail.mud.yahoo.com ([66.163.178.121])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HFCOA-0004tA-FW
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 08:44:54 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

First of all, thank you and congratulations for the
nfs project on linux.

That being said, I'm the author of a small nfs manager
named vsman, see http:/vsman.sourceforge.net.
In order to enhance it, I unfortunately need to have a
better vision of the relationship between clients
hosts and the volume(s) they mount.

Applications such as showmount rely on rpc procedures
that return pointers to a linked list of mounted
volumes. Each mounted volume is described, as you
know, by a struct mountbody entry.

So far so good, but browsing the entries of the linked
list doesn't give you a clear idea of which host
mounts which direfctory.

The various entries of the linked list seem added
according to a event based scheme, rather than a
logical link between the client host and its mounted
volumes.

Therefore, I naturally suggest, if possible for a next
release of the nfs utilities, that the mountlist will
be sorted out, so that one can clearily identify the
mounted volumes and their clients.

So, I'll be able to release a version of vsman, that
will finally display the correct client hostnames or
IP addresses. This issue is an endemic drawback to
vsman.

Thank you for considering my request.

Best regards,

Christophe Gros. 


 
____________________________________________________________________________________
Yahoo! Music Unlimited
Access over 1 million songs.
http://music.yahoo.com/unlimited

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
