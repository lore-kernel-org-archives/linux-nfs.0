From: Marc Kalberer <Marc.Kalberer@programmers.ch>
Subject: mount --bind empty
Date: Tue, 01 May 2007 22:01:58 +0200
Message-ID: <46379CB6.8050201@programmers.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiyXc-0006Kk-Ps
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 13:01:40 -0700
Received: from smtp1.infomaniak.ch ([84.16.68.89])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiyXb-0006xG-GM
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 13:01:43 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,
My nfs drive is getting full, so I mount --bind a folder located in a 
partition with a lot of space.

Env: 2.6.4-54.5-smp, nfs3

lets say
(server) nfs  data dir  is /home/data
(server) I mount --bind /var/dir_new_part    /home/data/newpart_space
(client) cannot read any content inside /home/data/newpart_space. (Read 
is empty, write is denied for any user, with all /etc/exports different 
combination - no_hide no_sub_tree

is there any way to acheive this ? any hints is welcome ... ;-)

Rem: I had to mount --bind because the partition added is not empty, so 
I could not mount it directly to /home/data/newpart_space

++
Marc




-- 
Programmers.ch
Solutions libres et Opensources
Tel: ++41 76 44 888 72
Site: http://www.programmers.ch
Site: http://openprojects.ch


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
