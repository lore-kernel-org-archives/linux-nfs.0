From: Martynas Buozis <martynas@ti.com>
Subject: nfsroot problems on RedHat 8 with kernel linux-2.4.18-27.8.0
Date: Fri, 23 May 2003 14:07:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ECE0EF3.5080004@ti.com>
Reply-To: martynas@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from news.ti.com ([192.94.94.33] helo=dragon.ti.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JBKQ-00089X-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 05:07:19 -0700
Received: from dlep50.itg.ti.com ([157.170.141.74])
	by dragon.ti.com (8.12.9/8.12.9) with ESMTP id h4NC7H1p016402
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 07:07:17 -0500 (CDT)
Received: from ffab.tide.ti.com (localhost [127.0.0.1])
	by dlep50.itg.ti.com (8.12.9/8.12.9) with ESMTP id h4NC7FlM025010
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 07:07:16 -0500 (CDT)
Received: from ti.com (terbium [137.167.218.81])
	by ffab.tide.ti.com (8.12.6/8.12.6) with ESMTP id h4NC7FZt025128
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 14:07:15 +0200 (MEST)
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

Hello


I have problems with nfsroot module when root file system is shared on 
EMC Cellerra. The problem is, that  Celerra needs the
client's name and IP address to authenticate the mount request. This
information is usually sent through the RPC authentication data. But 
nfsroot module does not send this data during mount, so Celerra denies 
request. This was a conclusion by EMC support after analyzing network's 
traffic between disk less station and Celerra.

I was looking what can be changed in /usr/src/linux-2.4/fs/nfs/nfsroot.c 
code, but I am not very experienced in this. Maybe somebody can help me 
to solve this problem ? Maybe that's wrong file were too look for 
changes ? Is it possible to make changes like this and is it possible to 
get official fix fro this problem ?

Thank you very much for your kind responses.

With best regards
Martynas Buozis



-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
