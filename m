From: jp@pour.midcoast.com
Subject: performance question
Date: Mon, 31 Mar 2003 16:37:39 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030331213739.25218.qmail@pour.midcoast.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pour.midcoast.com ([206.26.226.21] ident=qmailr)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1906u1-0004tB-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 13:33:13 -0800
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

I have looked through the last couple months of mailing lists archives and 
reviewed the material at nfs.sourceforge.net and the list to netapp's nfs 
suggestions.

I am trying to get real good performance out of NFS. So far the best I've 
got is about 1/10 of the local speed with dedicated 100mbps ethernet 
between fairly speedy computers.

Here's the setup.

Server (coffeepot) - Athlon XP2000, Suse 8.1, 2.4.21-pre6 kernel from
kernel.org, boots to an ata100 drive, promise rm8000 external hardware 
raid5 array on adaptec Adaptec AHA-2940U/UW/D controller, 3com 3c905C 
forced to 100-FD with "/sbin/mii-tool -F 100baseTx-FD eth1".

coffeepot:~ # mount |grep sda
/dev/sda1 on /shared/home type ext2 (rw,noatime)
/dev/sda2 on /shared/backup type ext2 (rw,noatime)
/dev/sda3 on /shared/logs type ext2 (rw,noatime)

coffeepot:~ # cat /etc/exports
/shared/home    10.0.34.0/24(rw,no_root_squash,async)
/shared/backup/ 10.0.34.0/24(ro,root_squash,async)
/shared/logs    10.0.34.0/24(rw,root_squash,async)

coffeepot:~ # bonnie++ -d /shared/home/jp -s 1600 -r 512 -u jp
Version 1.01d       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
coffeepot     1600M 40206  42 39934  13  9989   3 19782  22 21765   5 317.2   1
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16  2675  99 +++++ +++ +++++ +++  2759  99 +++++ +++  4360 100

Performance is fairly kickin' here locally.

Connected through a HP4000M switch set for full duplex 100baseT on the same
switch linecard for both ports is the client.

http://midcoast.com/~jp/10.0.15.2_15-day.png is the network traffic between the
two computers showing two bonnie++ tests on the right of the graph. There is 
no packet loss between the computers when tested with flood pings or regular pings.

Client info.(froth) - Athlon XP2200, Suse 8.1, 2.4.21-pre6 kernel from
kernel.org, boots to a ata-100 drive. 3com 3c905C forced to 100-FD with
"/sbin/mii-tool -F 100baseTx-FD eth1".

froth:~ # cat /etc/mtab
10.0.34.1:/shared/backup /shared/backup nfs rw,tcp,hard,intr,rsize=1024,wsize=1024,addr=10.0.34.1 0 0
10.0.34.1:/shared/logs /shared/logs nfs rw,tcp,hard,intr,rsize=1024,wsize=1024,addr=10.0.34.1 0 0
10.0.34.1:/shared/home /shared/home nfs rw,udp,hard,intr,rsize=1400,wsize=1400,addr=10.0.34.1 0 0

same bonnie++ command:
Version 1.01d       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
froth         1600M  2724   5  2764   4  1395   3  2778   5  2848   3  33.5   0
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16  1175   3  5061  12  2840  10  1208   5  5723  11  1684   4
froth,1600M,2724,5,2764,4,1395,3,2778,5,2848,3,33.5,0,16,1175,3,5061,12,2840,10,1208,5,5723,11,1684,4


I get about 2700 K/sec and seeks go from 317 to 33/sec. The transfer speed
matches the network traffic graph. I would like to do better than 2700ish.

What is possible for me to improve without moving to Gig-Ethernet?

I've tried both TCP and UDP NFS. rsize & wsize or 1024,1400,4096,8192. The larger
two have horrid performance due to packet fragmentation. Like magnitudes worse.
1024, 1400, UDP and TCP all have similar performance for me.

Also, is it possible to clear the counters in nfsstat?

MUCH TIA,
Jason



-- 
/*
Jason Philbrook   |   Midcoast Internet Solutions - Internet Access,
    KB1IOJ        |  Hosting, and TCP-IP Networks for Midcoast Maine
 http://f64.nu/   |             http://www.midcoast.com/
*/


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
