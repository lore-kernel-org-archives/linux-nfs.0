From: Oliver Korff <oliver.korff@credativ.de>
Subject: nfs export switchs to readonly
Date: Fri, 2 Aug 2002 16:00:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020802140019.D26C5352D0@credativ.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cdt1.tz-juelich.de ([195.37.52.66] helo=www.credativ.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17acuo-0006Iv-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 06:56:26 -0700
Received: from credativ.de (dativ.credativ.de [172.26.14.11])
	by www.credativ.de (Postfix) with ESMTP id 0F3BBD6680
	for <nfs@lists.sourceforge.net>; Fri,  2 Aug 2002 16:00:23 +0200 (CEST)
Received: from there (localhost [127.0.0.1])
	by credativ.de (Postfix) with SMTP id D26C5352D0
	for <nfs@lists.sourceforge.net>; Fri,  2 Aug 2002 16:00:19 +0200 (CEST)
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

Hi, 

I've the following trouble: 
after some hard traffic or a nfs restart my exports sometimes switches to 
"ro". I don't have that problem if I boot the server first and all clients 
connect afterwards. But that gets a little messy because I've got 110 
clients....
If I use "exportfs -rv" this usually solves the problem, but not always. 


kernelversion 2.4.18
nfs Version 1.0
distribution: debian/woody
 
cat /var/lib/nfs/xtab | grep myotherhost
 /data01 
myotherhost.foo.bar(ro,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,
secure_locks,mapping=identity,anonuid=-2,anongid=-2)

# /etc/exports: the access control list for filesystems which may be exported
#		to NFS clients.  See exports(5).
#
/data01	myhost.foo.bar(rw,no_root_squash)
/data01	my*.foo.bar(rw)
/data01	www-linux.foo.bar(rw)
/data01	*.foo.bar(ro)
-- 
Oliver Korff, credativ GmbH
Karl-Heinz-Beckurts-Str. 13
52428 Jülich, Germany
Tel.:  +49 (2461) 69071-0
Fax:   +49 (2461) 69071-1


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
