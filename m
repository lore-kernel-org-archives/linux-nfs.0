From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Thu, 19 Apr 2007 15:37:23 -0500
Message-ID: <4627D303.8060009@amd.com>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: julia bauer <julia.bauer@amd.com>, nfs@lists.sourceforge.net
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HedNv-0006O9-4B
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 13:37:43 -0700
Received: from outbound-cpk.frontbridge.com ([207.46.163.16]
	helo=outbound1-cpk-R.bigfish.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HedNw-00033t-8R
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 13:37:45 -0700
In-Reply-To: <1177007479.6623.14.camel@heimdal.trondhjem.org>
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

Myklebust wrote:
 > On Thu, 2007-04-19 at 13:24 -0500, Gregory Baker wrote:
 >
 >> Ideas?
 >
 > Perhaps a limitation on the number of entries in the netgroup on the
 > server?
 >
 > Cheers
 >   Trond

I've seen past Netapp/netgroups non-happiness.  In this case the
netgroup is relatively small... I tested quickly by moving the rhel5 
system (adcgar04) to the top of the netgroup list with no affect.

[greg@apathy greg]$ show_netgroup volexport-pandora
adcgar04.amd.com   <-------RHEL 5 64 system
nextimon.amd.com
i-sif1.amd.com
apathy.amd.com
build-lipc2.amd.com
build-el3-32.amd.com
build-el3-64.amd.com    <------RHEL 3 64 system
build-el5-32.amd.com
build-el5-64.amd.com
build-sl10-32.amd.com
build-sl10-64.amd.com
hummus01.amd.com
loriol.amd.com
coolhand.amd.com
orkney.amd.com
purgatory.amd.com
reverse.amd.com
sideways.amd.com
testpig3.amd.cfffffadfm
texas2s20.amd.com
xhaust.amd.comrond

---+What the filer thinks

[greg@apathy greg]$ sudo rsh eng exportfs -c 163.181.61.69 
/vol/vol4/pandora/pandora-k26_g25_64-2  root
exportfs: 163.181.61.69 has root access to /vol/vol4/pandora

[greg@apathy greg]$ sudo rsh eng exportfs -c 163.181.61.69 
/vol/vol4/pandora/pandora-k26_g25_64-2  rw
exportfs: 163.181.61.69 has rw access to /vol/vol4/pandora

[greg@apathy greg]$ host 163.181.61.69
69.61.181.163.in-addr.arpa domain name pointer adcgar04.amd.com.

---+ BAD RHEL 5 64 system

[root@adcgar04 /]# mount  eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2

[root@adcgar04 mnt2]# mount -v | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
(rw,addr=163.181.34.137)

[root@adcgar04 mnt2]# cat /proc/mounts | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0

[root@adcgar04 mnt2]# touch asdf
touch: cannot touch `asdf': Read-only file system

---+GOOD RHEL 3 64 system

[root@build-el3-64 root]# mount  -o tcp 
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2

[root@build-el3-64 root]# mount -v | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
(rw,tcp,addr=163.181.34.137)

[root@build-el3-64 root]# cat /proc/mounts | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
rw,v3,rsize=32768,wsize=32768,hard,tcp,lock,addr=eng 0 0

[root@build-el3-64 root]# cd /mnt2/

[root@build-el3-64 mnt2]# touch asdf

[root@build-el3-64 mnt2]# ls -la asdf
-rw-r--r--    1 root     root            0 Apr 19 15:35 asdf





-- 
----------------------------------------------------------------------
Greg Baker                                         512-602-3287 (work)
gregory.baker@amd.com                              512-602-6970 (fax)
5204 E. Ben White Blvd MS 625                      512-555-1212 (info)
Austin, TX 78741





-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
