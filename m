From: "Ozy Ali" <ozzeee@hotmail.com>
Subject: (no subject)
Date: Wed, 03 Apr 2002 11:03:33
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F72IUsRWkPVbuEaRJe70000acfe@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Received: from f72.law4.hotmail.com ([216.33.149.72] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16siYK-0005Bp-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Apr 2002 03:03:44 -0800
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi,
   in an attempt to try and get around the port mapper failure error i was 
having earlier (already posted about it), i changed the network card and now 
have a 3com card that gets auto detected from the nfs installation floppy.  
it takes me str8 to the ip address prompt, followed by the nfs server 
details.  the problem now is, that when i enter the information for the 
server, it goes t ocheck and then comes back with rpc: unable to send.  the 
nfs server is ,as far as i know, setup correctly.  the ip adress has been 
allowed in exportfs and also host.allow. nfs services are started up 
succesfully using the command "/etc/rc.d/init.d/nfs start " .wot is the 
problem here? can anyone shed some light ont he situation please?

O.

_________________________________________________________________
MSN Photos is the easiest way to share and print your photos: 
http://photos.msn.com/support/worldwide.aspx


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
