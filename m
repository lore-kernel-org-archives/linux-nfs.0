From: "Guolin Cheng" <guolin@alexa.com>
Subject: "nfs warning: mount version older than kernel" reported for 2.6.4 kernel on Fedora Core 1.0
Date: Fri, 19 Mar 2004 10:11:24 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41089CB27BD8D24E8385C8003EDAF7AB084833@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4OSw-0008Cb-LQ
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 10:11:30 -0800
Received: from birdwell-public.alexa.com ([67.107.182.10] helo=karl.presidio.alexa.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B4OSw-00054E-4m
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 10:11:30 -0800
To: "NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
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

Hi, all,

  Nfs complains when I compile and use kernel 2.6.4 on Fedora Core 1.0. =
the warning message is:

host1> dmesg=20
.....
 Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
.....

host1> rpcinfo -p localhost
hello06.alexa.com guolin 138% rpcinfo -p localhost
   program vers proto   port
...
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
...
    100011    1   udp    906  rquotad
    100011    2   udp    906  rquotad
    100011    1   tcp    909  rquotad
    100011    2   tcp    909  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100005    1   udp    947  mountd
    100005    1   tcp    971  mountd
    100005    2   udp    947  mountd
    100005    2   tcp    971  mountd
    100005    3   udp    947  mountd
    100005    3   tcp    971  mountd
    300019    1   tcp    937  amd
    300019    1   udp    938  amd
....
hello06.alexa.com guolin 139%=20


 Anyone know why? and how to solve it? Thanks a lot.


 --Guolin Cheng



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
