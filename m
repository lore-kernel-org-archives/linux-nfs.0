From: Peter Astrand <peter@cendio.se>
Subject: Re: userspace NFS daemon
Date: Mon, 6 Sep 2004 09:41:31 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409060935290.20425-100000@maggie.lkpg.cendio.se>
References: <20040905220120.GA29596@janus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4E88-00049f-Uf
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 00:41:36 -0700
Received: from cheddar.cendio.se ([193.12.253.77] helo=mail.cendio.se)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4E87-00034P-FS
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 00:41:36 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 199D325DA35
	for <nfs@lists.sourceforge.net>; Mon,  6 Sep 2004 09:41:31 +0200 (CEST)
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <20040905220120.GA29596@janus>
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

On Mon, 6 Sep 2004, Frank van Maarseveen wrote:

>Anyway, I found this:
>
>        http://clusternfs.sourceforge.net

Another alternative is unfs3: http://unfs3.sourceforge.net/. It provides 
the same cluster extensions, and also has some other interesting features:

* NFSv3 instead of NFSv2 (it's easier to write userspace NFS servers with 
v3, since the filehandle is larger.)

* Can run the MOUNT and NFS protocol on the same TCP port. Very useful 
when tunneling through SSH. 

* Can export removable devices, even with FAT filesystems. 

* Supports mount-time passwords. When passwords are used, the filehandles 
are scrambled with the password. 


-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
