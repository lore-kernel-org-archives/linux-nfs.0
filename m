From: ms419@freezone.co.uk
Subject: F_SETLK failed, file already locked by pid 0
Date: Sun, 22 Aug 2004 15:50:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <A4B2A13E-F48D-11D8-A02C-000A95C71776@freezone.co.uk>
Mime-Version: 1.0 (Apple Message framework v613)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bz1AL-00032Y-DH
	for nfs@lists.sourceforge.net; Sun, 22 Aug 2004 15:50:21 -0700
Received: from outbound02.telus.net ([199.185.220.221] helo=priv-edtnes09.telusplanet.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bz1AK-0002ii-08
	for nfs@lists.sourceforge.net; Sun, 22 Aug 2004 15:50:21 -0700
Received: from tor.lat ([154.5.5.164]) by priv-edtnes09.telusplanet.net
          (InterMail vM.6.01.03.03 201-2131-111-105-20040624) with ESMTP
          id <20040822225010.WTFN14828.priv-edtnes09.telusplanet.net@tor.lat>
          for <nfs@lists.sourceforge.net>; Sun, 22 Aug 2004 16:50:10 -0600
Received: from [192.168.179.43] (fis.lat [192.168.179.43])
	by tor.lat (Postfix) with ESMTP id B2A3F11E8F3
	for <nfs@lists.sourceforge.net>; Sun, 22 Aug 2004 15:50:09 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

I suspect locking isn't working:

F_SETLK failed, file already locked by pid 0

I encounter this error with a user mode linux root image on an NFS 
mount, but not with an image on a local file system. An image on an NFS 
mount should work, provided locking works.

The NFS client is running NFS 1.0.6 & a custom 2.6.7 kernel. The NFS 
server is running NFS kernel server 1.0.6 & a custom 2.4.27 kernel. 
Everything I've read claims that locking is now implemented in the 
linux NFS kernel server. A lockd process is running on both the client 
& the server. According to all the documentation I've read, locking 
should be working; what am I missing? Pointers to diagnostic 
information, configuration, & documentation much appreciated!

Why isn't locking working?

Thanks,

Jack



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
