From: Oliver Beowulf Friedrich <beowulflinux@gmx.de>
Subject: Problem with NFS-Exports
Date: Wed, 17 Nov 2004 07:58:14 +0100
Message-ID: <419AF686.7030503@gmx.de>
References: <482A3FA0050D21419C269D13989C61130435EB6A@lavender-fe.eng.netapp.com>	 <1100622780.10975.51.camel@lade.trondhjem.org>	 <419A3672.8040305@int-evry.fr> <1100628498.7570.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CUJnc-0000jT-P0
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 23:00:16 -0800
Received: from pop.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CUJna-0007eT-N5
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 23:00:16 -0800
In-Reply-To: <1100628498.7570.6.camel@lade.trondhjem.org>
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

Greetings @ all,

I'm new here on the list, but already have a simple question to you.

I'm using Gentoo linux, currently, having a working server@home with 
Gentoo which exports Gentoo's temporary folders out to my workstations.

server root # cat /etc/exports
/home           192.168.0.0/24(rw,async)
/usr/portage    192.168.0.0/24(rw,no_root_squash,async,mp)
/tmp 
192.168.0.0/24(rw,no_root_squash,insecure_locks,async,mp)
/mnt/data       192.168.0.0/24(rw,no_root_squash,mp,sync)
/mnt/backup     192.168.0.0/24(rw,no_root_squash,mp,sync)


One Workstation is now on compiling a new fresh Gentoo Linux, so I 
startet with booting from Gentoo-2004.3 liveCD, mounting local 
filesystems, mounting nfs filesystems, chrooting and starting to 
compile.

So fine, but while compiling, I get the following Error messages 
printed out quit often:

lockd: failed to monitor 192.168.0.2
lockd: cannont monitor 192.168.0.2

So whats going on there? Sometimes it's going so far, that my new 
WKS cannot compile, cause of:

lockd: server ist not responding
lockd: still trying OK

How do i get this solved? With my previus installation it worked 
fine, I had only NFS-Server Support compiled into Kernel, now I have 
NFSV3-Server Support compiled in.

My Server now is not used to heavy, only a little Samba Server for 
my (only) Windows-Box where MP3's are shared to...

On my last installation on my Server I used distcc while compiling, 
and even that did not lead to such Error Messages...

Thanks for reading

BeowulfOF




-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
