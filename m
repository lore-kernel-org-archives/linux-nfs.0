From: Alexander Bergolth <leo@strike.wu-wien.ac.at>
Subject: problems using devices via nfsvers3 with 2.6.6. and 2.6.7
Date: Tue, 06 Jul 2004 20:41:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40EAF250.2080202@strike.wu-wien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: neilb@cse.unsw.edu.au
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bhusg-0000eE-9U
	for nfs@lists.sourceforge.net; Tue, 06 Jul 2004 11:41:26 -0700
Received: from strike.wu-wien.ac.at ([137.208.8.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bhusf-0001N0-Ib
	for nfs@lists.sourceforge.net; Tue, 06 Jul 2004 11:41:25 -0700
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

Hi!

I'm getting "permission denied" errors when trying to access devices 
from a 2.6 client that are mounted via nfsvers3 and exported read-only 
by the server. Using nfsvers2 or a 2.4 kernel doesn't show this error.

I could reproduce this with kernel 2.6.6-1.435.2.3 (from FC-2) and with
kernel 2.6.7-1.456_4.rhfc2.at (from ATrpms).

Any hints?

---------- Client using kernel 2.6.6-1.435.2.3 ----------
# mount -oro,nfsvers=3 ariel:/dev /mnt

# ls -l /mnt/null
crw-rw-rw-  1 root root 1, 3 Sep 15  2003 /mnt/null

# echo test > /mnt/null ; echo $?
-bash: /mnt/null: Permission denied
1

# umount /mnt
# mount -oro,nfsvers=2 ariel:/dev /mnt

# echo test > /mnt/null ; echo $?
0

---------- Client using 2.4.22 ----------
# mount -oro,nfsvers=3 ariel:/dev /mnt

# ls -l /mnt/null
ls: /mnt/null: Input/output error
crw-rw-rw-  1 root root 1, 3 Sep 15  2003 /mnt/null

# echo test > /mnt/null ; echo $?
0

---------- Server (2.4.22) ----------
# cat /etc/exports
/dev client1(ro,async,no_root_squash) client2(ro,async,no_root_squash)

--leo
-- 
-------------------------------------------------------
Alexander (Leo) Bergolth          leo@leo.wu-wien.ac.at
WU-Wien - Zentrum fuer Informatikdienste - Projektbuero


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
