From: Klaus Strebel <klaus.strebel@eigner.com>
Subject: RE: locking problem from HP-UX to Linux NFS Server
Date: Tue, 30 Jul 2002 10:03:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D464835.5040209@eigner.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Nguyen Thanh Bien <bien@thnt.com.vn>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from akira.ep-ag.com ([194.120.231.250] helo=akira.ep-ka.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZRyP-0004io-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Jul 2002 01:03:17 -0700
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

Hi all,

i have similar problems with locking from HP-UX clients to a Linux 
NFS-Server (HP-UX 10.20,11.0,11.1). Currenty i use SuSE 8.0 on the 
server with actual rpm's installed. I searched the support archives from 
HP and deja.com, found several people with the same problem but they 
never got an answer. I'll make an Software-Call at HP-Support, but i'm 
not sure if that make too much sense.

My workarout for this problem is, to symlink the directory where my 
applications want to create ther lock and datafiles to an NFS-share on 
an old Solaris 2.5 (without .1 !) box (and when i get the money to buy a 
Solaris box as NFS server i'll kick the Linux-NFS-servers ass ;-), could 
use it for my test Oracle-RAC). That's not what i like, but i gonna keep 
my shop going.

Hi nfs experts !
i'm using a Linux NFS server to store mailboxs from external HP-UX (ver
11.0), mail server soft ware on HP-UX is CommunigatePro (it runs as
root.mail user).

and i got a problem when start Communigate Pro:
- cannot lock files

my exports file is:
/data/data_mail  hp-ux-box(rw,no_root_squash,insecure,insecure_locks)

anyone can help me to fix this ?

-- Nguyen Thanh Bien Vietnamese Linux Users Group 
<http://vietlug.sourceforge.net>

-- 
Klaus Strebel
UNIX-Engineer
klaus.strebel@eigner.com
EIGNER - Precision Lifecycle Management -
<http://www.eigner.com>



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
