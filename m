From: Joel Franco =?iso-8859-1?Q?Guzm=E1n?= <joel.franco@3WT.com.br>
Subject: Insane permissions problem :)
Date: Wed, 17 Jul 2002 19:58:41 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020717225841.GC4853@netlocal.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 200-206-143-252.dsl.telesp.net.br ([200.206.143.252] helo=firewall.gds)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UxlG-0000XW-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Jul 2002 15:59:11 -0700
Received: from thor.gds ([192.168.1.41] ident=mail)
	by firewall.gds with esmtp (Exim 3.35 #1 (Debian))
	id 17Uxs9-0002w6-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Jul 2002 20:06:17 -0300
Received: from joel by thor.gds with local (Exim 3.35 #1 (Debian))
	id 17Uxkn-0001nc-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Jul 2002 19:58:41 -0300
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

	Please, i have a tree in other machine mounted in my local
machine using NFS v3. In that server machine, one example file shared 
is owned by the "intranet" group and this file have a write permission for the group there.
However i CAN'T write in it, like a ordinary user. In my local
/etc/groups file, i am in the "intranet" group and i should can to write
it. Both are 1007 group id (in my local machine and in the server)

# the mounted filesystem is mounted under /mnt/dirdocs. The export line in
# the server is (/etc/exports): 
/usr/local/apache/virtual/intranet.netlocal.com.br/contents/infraestrutura osiris(rw,no_root_squash) thor(rw,no_root_squash) poseidon(rw,no_root_squash)

root@thor# mount 
esparta:/usr/local/apache/virtual/intranet.netlocal.com.br/contents/infraestrutura
on /mnt/dirdocs type nfs (rw,addr=192.168.1.3)

#in my local machine 
joel@thor:/mnt/dirdocs/documentacao/TXT$ groups 
joel bin sys adm tty disk lp cdrom floppy tape sudo audio www-data
backup src video staff games nobody mysql shared admin intranet public
                                                          ^
						          |

joel@thor:/mnt/dirdocs/documentacao/TXT$ ls -l squid.txt 
-rw-rw-r--    1 jorge    intranet     1770 2002-06-24 13:29 squid.txt
joel@thor:/mnt/dirdocs/documentacao/TXT$ touch a
touch: criando `a': Permission denied
# HERE the problem. Why?


# The parent directory is with the intranet write permission ok.
joel@thor:/mnt/dirdocs/documentacao/TXT$ ls -l ..
total 12
drwxrwsr-x    2 jorge    intranet     4096 2002-06-28 17:12 HTML
drwxrwsr-x    2 jorge    intranet     4096 2002-06-28 17:15 OTHER
drwxrwsr-x    2 jorge    intranet     4096 2002-07-17 13:40 TXT
joel@thor:/mnt/dirdocs/documentacao/TXT$ 

Anyone have some idea?

Regards.

-- 
Joel Franco Guzmán
Network Analyst
3WT - Wireless Web World Tech
joel.franco@3WT.com.br
tel: +55 16 3371-4343
fax: +55 16 3371-9847
cel: +55 16 9787-0478


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
