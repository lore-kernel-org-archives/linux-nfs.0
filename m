From: "Deepa Chacko Pillai" <deepa.chacko@wipro.com>
Subject: Unmount in case of unreachable NFS server
Date: Mon, 5 May 2003 18:16:48 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <52C85426D39B314381D76DDD480EEE0CB681C5@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wiprom2mx1.wipro.com ([203.197.164.41])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19CfN7-0001LZ-00
	for <nfs@lists.sourceforge.net>; Mon, 05 May 2003 05:47:10 -0700
Received: from m2vwall5.wipro.com (m2vwall5.wipro.com [10.115.50.5])
	by wiprom2mx1.wipro.com (8.11.3/8.11.3) with SMTP id h45CkrN16167
	for <nfs@lists.sourceforge.net>; Mon, 5 May 2003 18:16:53 +0530 (IST)
To: <nfs@lists.sourceforge.net>
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

Can I unmount a file system, mounted from server 'A', if the server 'A' =
is down and the client has open files on it? If there are no open =
references to the filesystem, I saw it could be unmounted if I soft =
mount the FS.

I will explain my requirement with an example. Suppose I have 3 nodes A, =
B and C. I mount a filesystem from node A onto node C. The device =
containing the filesystem is accessible from node B also (shared disk). =
If node A fails, I want to migrate the FS to node B. Once the FS is =
migrated, I have to remount the FS on node C. On client C, I am unable =
to unmount the FS as it has some files open. Even force unmount failed. =
I can however mount the FS from node B onto the same mount point again =
(overlay mount). This would mean I need to keep track of the number of =
such mounts. I would like to know if there is any other way to do this.

Another possibility I thought of is IP failover. However, it will =
confuse locking I guess.
I am using Red Hat Linux 2.4.19.

Any help would be much appreciated.

Thanks
Deepa





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
