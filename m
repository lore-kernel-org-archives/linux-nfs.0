From: Erik Enge <eenge@prium.net>
Subject: Multiple mounts to a rpc.mountd with port specified.
Date: 25 Nov 2002 12:20:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <871y59efci.fsf@prium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from main.gmane.org ([80.91.224.249])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18GN09-0003Tm-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Nov 2002 09:26:30 -0800
Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 18GMty-0002yw-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Nov 2002 18:20:06 +0100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi.

I'm currently setting up NFS through a firewall and my current strategy
(which seems to work fine) is to specify a port for the rpc.mountd so I
can predict what to open on the firewall.

Will this impede performance or functioning at all with multiple mounts
(over the same port)?

I have opened ports 111, 2049 and 32700 (port for mountd) on the
firewall and from the logs I can see that I'm not dropping any packets.
I am also running lockd, so does this mean that lockd uses 111, 2049 or
32700 or is it not running?  Is there a specific port for lockd or do I
specify the port on rpc.statd and then lockd will use that?

Thanks for any answers,

Erik Enge
Software Engineer
Professional Reviews Inc.




-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
