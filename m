From: Jose Santiago <jsantiago@chrysalisdev.com>
Subject: getfh failed: Operation not permitted
Date: Mon, 12 Aug 2002 18:30:00 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D5844F8.5080708@chrysalisdev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 89.levincom.com ([198.78.56.89] helo=chrysalis-sbs1.chrysalisdev.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eOdW-0003xz-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 16:30:10 -0700
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

Server Name: bfs1
Client Name: rtr01

I am having problems mounting bfs1:/data on NFS client rtr01 . The 
server log says:

Aug 12 14:15:27 bfs1 rpc.kmountd: getfh failed: Operation not permitted

when I attempt the mount.

The client can mount bfs1:/ bfs1:/data/backup and all of the other mount 
points and subdirectories under the mount points except for bfs1:/data 
and other subdirectories under it. Other NFS clients can mount 
bfs1:/data and all mount points just fine.

A pointer in the right direction would be much appreciated.

Both client and Server:
   Kernel version 2.4.19pre1
   nfs-utils version 0.3.3
   mount version 2.11n

Server /etc/exports:
/ \
     bfs1.chrysalisdev.com(no_root_squash,rw,insecure,nohide) \
     inet1.chrysalisdev.com(no_root_squash,rw,insecure,nohide) \
     wsa147.chrysalisdev.com(no_root_squash,rw,insecure,nohide) \
     127.0.0.0/255.0.0.0(no_root_squash,rw,insecure,nohide) \
     10.0.0.0/255.0.0.0(rw,insecure,nohide)
/data \
     bfs1.chrysalisdev.com(no_root_squash,rw,insecure,nohide) \
     inet1.chrysalisdev.com(no_root_squash,rw,insecure,nohide) \
     wsa147.chrysalisdev.com(no_root_squash,rw,insecure,nohide) \
     127.0.0.0/255.0.0.0(no_root_squash,rw,insecure,nohide) \
     10.0.0.0/255.0.0.0(rw,insecure,nohide)
/data/backup \
     127.0.0.0/255.0.0.0(no_root_squash,rw,insecure,nohide) \
     10.0.0.0/255.0.0.0(no_root_squash,rw,insecure,nohide) \
     172.16.0.0/255.240.0.0(no_root_squash,rw,insecure,nohide) \
     192.168.0.0/255.255.0.0(no_root_squash,rw,insecure,nohide)
/cdrom \
     *(ro,insecure,nohide)
/floppy *(rw,insecure,nohide)

Server exportfs -v:
/data bfs1.chrysalisdev.com(rw,async,wdelay,nohide,insecure,no_root_squash)
/data inet1.chrysalisdev.com(rw,async,wdelay,nohide,insecure,no_root_squash)
/data 
wsa147.chrysalisdev.com(rw,async,wdelay,nohide,insecure,no_root_squash)
/ bfs1.chrysalisdev.com(rw,async,wdelay,nohide,insecure,no_root_squash)
/ inet1.chrysalisdev.com(rw,async,wdelay,nohide,insecure,no_root_squash)
/ wsa147.chrysalisdev.com(rw,async,wdelay,nohide,insecure,no_root_squash)
/data/backup 
127.0.0.0/255.0.0.0(rw,async,wdelay,nohide,insecure,no_root_squash)
/data/backup 
10.0.0.0/255.0.0.0(rw,async,wdelay,nohide,insecure,no_root_squash)
/data/backup 
172.16.0.0/255.240.0.0(rw,async,wdelay,nohide,insecure,no_root_squash)
/data/backup 
192.168.0.0/255.255.0.0(rw,async,wdelay,nohide,insecure,no_root_squash)
/data 127.0.0.0/255.0.0.0(rw,async,wdelay,nohide,insecure,no_root_squash)
/data 10.0.0.0/255.0.0.0(rw,async,wdelay,nohide,insecure,root_squash)
/ 127.0.0.0/255.0.0.0(rw,async,wdelay,nohide,insecure,no_root_squash)
/ 10.0.0.0/255.0.0.0(rw,async,wdelay,nohide,insecure,root_squash)
/floppy         <world>(rw,async,wdelay,nohide,insecure,root_squash)
/cdrom          <world>(ro,async,wdelay,nohide,insecure,root_squash)



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
