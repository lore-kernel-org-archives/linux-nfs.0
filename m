From: "Martynas Buozis" <martynas@ti.com>
Subject: Re: nfsroot problems on RedHat 8 with kernel linux-2.4.18-27.8.0
Date: Sat, 24 May 2003 06:33:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003401c321ad$9a438180$6464a8c0@foxie>
References: <3ECE0EF3.5080004@ti.com><shs4r3lx1ux.fsf@charged.uio.no><3ECE2479.3000706@ti.com> <16078.12509.988134.109974@charged.uio.no>
Reply-To: "Martynas Buozis" <martynas@ti.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from go4.ext.ti.com ([192.91.75.132])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JQiq-0000nS-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 21:33:32 -0700
To: <trond.myklebust@fys.uio.no>
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

Hi

> NFS uses the hostname as specified in /proc/sys/kernel/hostname (alias
> system_utsname.nodename) whether or not it is running from NFSroot.
>
> If you have set the hostname in bootp, then ipconfig will set it, and
> will print it out as 'host=%s" in the "IP-Config: Complete"
> information...

As I wrote in my previous letter - ipconfig sets host name and prints it out
as "host=testmws" (testmws is host name) in "IP-Config: Complete". But
rootnfs module is not sending full informtion as required by Celerra, so
mount request is denied. When I use mount from command line on booted RedHat
8 system to mount same file system - it sends all required information and
Celerra accepts mount request.


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
