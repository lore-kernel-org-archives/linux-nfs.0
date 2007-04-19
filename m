From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Thu, 19 Apr 2007 17:23:56 -0500
Message-ID: <4627EBFC.2090704@amd.com>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: julia bauer <julia.bauer@amd.com>, nfs@lists.sourceforge.net
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hef3C-0000bH-4i
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 15:24:26 -0700
Received: from outbound-cpk.frontbridge.com ([207.46.163.16]
	helo=outbound2-cpk-R.bigfish.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hef3E-000132-C7
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 15:24:28 -0700
In-Reply-To: <1177020662.6628.30.camel@heimdal.trondhjem.org>
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


Trond Myklebust wrote:
 > On Thu, 2007-04-19 at 15:37 -0500, Gregory Baker wrote:
 >
 >> ---+ BAD RHEL 5 64 system
 > ...
 >> [root@adcgar04 mnt2]# cat /proc/mounts | grep mnt2
 >> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs
 >> 
ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 

 >> 0 0
 >
 > That would be your problem right there. Is the same volume perhaps
 > mounted read-only somewhere else on the same client? That is no longer
 > allowed.
 >
 > Cheers
 >   Trond
 >

Ah, news to me!

So if you mount a volume ro at one mount point /mnt1 and then try to 
mount the same volume rw at a second mount point /mnt2 you'll run into 
problems?  Apologies, didn't catch this in release notes.  Thanks!

--Greg

---+ A New Beginning

[root@adcgar04 /]# umount -a -t nfs

[root@adcgar04 /]# mount -v | grep pandora

[root@adcgar04 /]# cat /proc/mounts | grep pandora

[root@adcgar04 /]# mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2

[root@adcgar04 /]# mount -v | grep pandora
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
(rw,addr=163.181.34.137)

[root@adcgar04 /]# cat /proc/mounts | grep pandora
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
rw,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0

[root@adcgar04 /]# touch /mnt2/asdf

---+ The ro Strikes Back

[root@adcgar04 /]# mount -o ro 
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt1

[root@adcgar04 /]# mount -o rw 
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2

[root@adcgar04 /]# mount -v | grep mnt
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt1 type nfs 
(ro,addr=163.181.34.137)
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
(rw,addr=163.181.34.137)

[root@adcgar04 /]# cat /proc/mounts | grep mnt
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt1 nfs 
ro,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
ro,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0

[root@adcgar04 /]# touch /mnt2/asdf
touch: cannot touch `/mnt2/asdf': Read-only file system





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
