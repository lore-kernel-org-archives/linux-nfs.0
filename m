From: Sampo Nurmentaus <audiopoppi-13@audioriders.fi>
Subject: Weird error with nfs server and an embedded linux system.
Date: Mon, 29 Jul 2002 16:01:36 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0207291531280.12454-100000@localhost>
References: <3D451F23.92E4DA72@moving-picture.com>
Reply-To: <sampo.nurmentaus@audioriders.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs150121.pp.htv.fi ([213.243.150.121])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZA9s-0005X9-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 06:01:56 -0700
Received: from [120.100.100.14] (rhols129.adsl.netsonic.fi [194.29.198.129])
	by cs150121.pp.htv.fi (8.11.6/8.11.6) with ESMTP id g6TD1jI24054
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 16:01:50 +0300
To: <nfs@lists.sourceforge.net>
In-Reply-To: <3D451F23.92E4DA72@moving-picture.com>
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



Hello folks,

I ported all the nfs stuff to our embedded system running 2.4.14
on cris platform.  All the daemons start up nicely except
the statd that prints to log that:

Jul 29 12:58:06 noisy25 statd[124]: Version from Hell! Starting

But it starts up anyway.

When I try to mount a share it ses in syslog that mount request is
authenticated and my laptops ip appears in xtab but still the mount fails
with fallowing error message:

[root@kombo root]# mount -t nfs -o nolock 120.100.100.25:/tmp/hd /mnt/keke/
mount: RPC: Remote system error


When I run rpcinfo on my laptop against the server
I get fallowing output:

[root@kombo root]# rpcinfo -p 120.100.100.25
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   2048  nlockmgr
    100021    3   udp   2048  nlockmgr
    100021    4   udp   2048  nlockmgr
    100011    1   udp    715  rquotad
    100011    2   udp    715  rquotad
    100005    1   udp   2050  mountd
    100005    1   tcp   2059  mountd
    100005    2   udp   2050  mountd
    100005    2   tcp   2059  mountd
    100005    3   udp   2050  mountd
    100005    3   tcp   2059  mountd
    100024    1   udp   2051  status
    100024    1   tcp   2060  status

And my xtab on the embedded board includes the ip of my laptop
as it should.


Any ideas what might be going wrong?


Thanks,

Sampo Nurmentaus,
Software Developers,
Audio Riders Inc.



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
