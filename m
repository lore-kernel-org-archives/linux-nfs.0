From: Denis Vlasenko <vda@ilport.com.ua>
Subject: sys/tree.h is missing
Date: Wed, 9 Mar 2005 17:16:35 +0200
Message-ID: <200503091716.35737.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D92w1-0001zd-1C
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 07:17:17 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D92vu-0001sj-27
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 07:17:16 -0800
To: nfs@lists.sourceforge.net
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

Whil trying to compile libevent-1.0b:

ake  all-recursive
make[1]: Entering directory `/.share/usr/src2/libevent-1.0b/.obj'
Making all in .
make[2]: Entering directory `/.share/usr/src2/libevent-1.0b/.obj'
gcc -DHAVE_CONFIG_H -I. -I.. -I. -Icompat -Wal l -c ../event.c
../event.c:38:22: sys/tree.h: No such file or directory

I have sort-of Linux-from-scratch system and
I do not have such file. AFAIK /usr/include/sys
is part of glibc and mine is from glibc-2.3.2, but there is no tree.h,
I'm sure of it.

If you have it, please enlighten me where it should come from.
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
