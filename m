From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: NFSD Flow Control Using the TCP Transport
Date: Tue, 25 Mar 2003 06:33:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E803E7E.7040303@RedHat.com>
References: <3E78872B.5020702@RedHat.com> <20030320042454.496801DA3E6@brer.local.valinux.co.jp> <3E7B7853.4020605@RedHat.com> <20030324025133.924651DA3E6@brer.local.valinux.co.jp> <3E7F1F1D.8090206@RedHat.com> <20030325053205.1627C1DA3E6@brer.local.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, taka@valinux.co.jp, yamamoto@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xmgR-0004C1-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 03:33:36 -0800
To: MINOURA Makoto <minoura@valinux.co.jp>
In-Reply-To: <20030325053205.1627C1DA3E6@brer.local.valinux.co.jp>
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


MINOURA Makoto wrote:

>We do not start processing a request (enqueue the socket)
>before we get enough write space for any single request.  
>
Right.... This is exactly what is happening.  Three or four responses are
*not* being enqueued because there is not enough write space.  The
problem I'm seeing is those sockets are never getting re-enqueued.

Your patch is depending on the tcp layer calling svc_write_space() 
[when the write space is freed] to start the enqueuing of the sockets.
For some reason that is not happening in my case.....

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
