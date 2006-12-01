From: Weikuan Yu <wyu@ornl.gov>
Subject: NFS export of TMPFS
Date: Fri, 01 Dec 2006 16:46:41 -0500
Message-ID: <4570A2C1.3060707@ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqGDT-0003iW-H0
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 13:46:43 -0800
Received: from emroute1.ornl.gov ([160.91.4.119])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GqGDT-0004W0-Or
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 13:46:45 -0800
Received: from emroute1.ornl.gov ([127.0.0.1])
	by emroute1.ornl.gov (PMDF V6.3-x3 #31246)
	with ESMTP id <0J9M00HCZ75T3Q@emroute1.ornl.gov> for
	nfs@lists.sourceforge.net; Fri, 01 Dec 2006 16:46:42 -0500 (EST)
Received: from CONVERSION-DAEMON.emroute1.ornl.gov by emroute1.ornl.gov
	(PMDF V6.3-x3 #31246) id <0J9M00L0175TFW@emroute1.ornl.gov> for
	nfs@lists.sourceforge.net; Fri, 01 Dec 2006 16:46:41 -0500 (EST)
Received: from [160.91.44.76] (crossfire.ornl.gov [160.91.44.76])
	by emroute1.ornl.gov (PMDF V6.3-x3 #31246)
	with ESMTPSA id <0J9M00K4275TV8@emroute1.ornl.gov> for
	nfs@lists.sourceforge.net; Fri, 01 Dec 2006 16:46:41 -0500 (EST)
To: nfs@lists.sourceforge.net
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

I am trying to export a memory-based file system via NFS. However, I am 
not able to do with either ramfs or tmpfs. Here is the reported error. 
Is there a protection in NFS server to prevent this?

I also tried to use ramdisk. That worked, however, I am not able to 
create a ramdisk of more than 1G. I need to create a ramdisk that is 2G 
or more. Any insights on this.

I will be happy if I can get solutions for either of the approaches. Or 
is there any other alternatives?

Thanks,
Weikuan

[root@yoda1 ~]# mount -t tmpfs none /nfs
[root@yoda1 ~]# df -h /nfs
Filesystem            Size  Used Avail Use% Mounted on
none                  506M     0  506M   0% /nfs
[root@yoda1 ~]# ssh node0002
-bash-3.00# mount 192.168.1.254:/nfs /nfs
mount: 192.168.1.254:/nfs failed, reason given by server: Permission denied

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
