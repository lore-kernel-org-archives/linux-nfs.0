From: Jakob <jakob@free.fr>
Subject: problems writing to NFS shares
Date: Fri, 01 Nov 2002 23:40:48 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1036190448.3dc302f0c169c@imp.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from postfix2-1.free.fr ([213.228.0.9])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187kTG-0004lR-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 14:40:54 -0800
Received: from imp1-1.free.fr (imp1-1.free.fr [213.228.0.21])
	by postfix2-1.free.fr (Postfix) with ESMTP id E60D84C
	for <nfs@lists.sourceforge.net>; Fri,  1 Nov 2002 23:40:51 +0100 (CET)
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

Hi, I have a small home network with one file server and a couple of 
clients.  I want to host /home on the server to be able to work from any 
client.  however, I have trouble *writing* to the exported NFS share.

This seems mainly due to different user ids on client and server.  But
I thought this was handled by map_static ...  Anyway, here's my setup:

server (10.0.1.3 aka hatchoum) setup is:
----------------------------------------

jakob@hatchoum:~$ uname -a
Linux hatchoum 2.2.20 #1 Sat Apr 20 11:45:28 EST 2002 i686 unknown unknown 
GNU/Linux

jakob@hatchoum:~$ /usr/sbin/rpc.nfsd --version
Universal NFS Server 2.2beta47

jakob@hatchoum:~$ cat /etc/passwd |grep jakob
jakob:x:1000:33:Jakob,,,:/home/jakob:/bin/bash

jakob@hatchoum:~$ cat /etc/exports
/home           10.0.0.0/255.255.0.0(rw,map_static=/etc/nfsuser.map)

jakob@hatchoum:~$ cat /etc/nfsuser.map
# Mapping for client sleepy:
#    remote     local
uid  0-499      -      # squash these
uid  1000       500    # just me for the moment
gid  100        33     # just the "users" group 

jakob@hatchoum:~$ df
Filesystem           1k-blocks      Used Available Use% Mounted on
/dev/hda1              1968368    384564   1483812  21% /
/dev/hdb5              5044128    985304   3802592  21% /mnt/rwstorage
/dev/hdb7              5044156    276852   4511072   6% /home
/dev/hdb6              5044156    720780   4067144  16% /projects
/dev/hdb8             10080488     32828   9535592   1% /backup
/dev/hdb9             14357980   2499132  11129500  19% /media


client (10.0.1.2 aka sleepy) setup:
-----------------------------------

/home/jakob> cat /etc/fstab | grep newhome
10.0.1.3:/home          /newhome        nfs             defaults 0 0

/home/jakob> cd /newhome
/newhome> ls -l
total 24
drwxr-sr-x   11 4294967294 4294967294     4096 Nov  1 12:53 jakob
drwx------    2 4294967294 4294967294    16384 Oct 22 18:09 lost+found

/newhome/jakob> touch test
touch: creating `test': Permission denied

/newhome/jakob> sudo touch test
touch: creating `test': Permission denied


I have trouble finding out whether the map_static option works.  
Also, what do these large uids and gids mean?  What do I need 
to change in order to be able to use the /home directories on 
the server?  I have spent the last couple of days RTFM, but with 
no real success, apart from learning that there are lots of
different NFS versions out there, and support for features may 
differ.

Thanks for any help you may give,

-- 
Jakob.


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
