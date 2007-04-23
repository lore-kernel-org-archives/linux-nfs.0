From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Mon, 23 Apr 2007 13:36:02 -0500
Message-ID: <462CFC92.2080201@amd.com>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: julia bauer <julia.bauer@amd.com>, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: gregory.baker@amd.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg3PO-0000oj-Cm
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 11:37:06 -0700
Received: from outbound-dub.frontbridge.com ([213.199.154.16]
	helo=outbound2-dub-R.bigfish.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hg3PQ-0007bF-8I
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 11:37:09 -0700
In-Reply-To: <4627EBFC.2090704@amd.com>
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


...closing the loop on what we've found out... it doesn't appear that a 
convenient workaround (at the mount level) exists.  We'll play around 
with local executable automount maps to see if that will work for us.

Thanks,

--Greg

*****
Indeed, now that I read that comment by Trond and went to the source 
code, I found out about upstream commit 
54ceac4515986030c2502960be620198dd8fe25b.

The idea is that having a single super_block structure per server per 
FSID prevents corner cases that can lead to corrupt dentry cache trees, 
prevents conflicting buffer cache contents to what ends up being the 
same file, and some other scary situations.

So the deal is, the mount flags (and NFS options) are set only the first 
time that a given combination of server and filesystem are mounted. If 
you ever mount the same filesystem from the same server on another 
mountpoint, you'll get the flags and options that were passed on to the 
first mount. There's no working around that.
*****

Gregory Baker wrote:
> Trond Myklebust wrote:
>  > On Thu, 2007-04-19 at 15:37 -0500, Gregory Baker wrote:
>  >
>  >> ---+ BAD RHEL 5 64 system
>  > ...
>  >> [root@adcgar04 mnt2]# cat /proc/mounts | grep mnt2
>  >> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs
>  >> 
> ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 
>  >> 0 0
>  >
>  > That would be your problem right there. Is the same volume perhaps
>  > mounted read-only somewhere else on the same client? That is no longer
>  > allowed.
>  >
>  > Cheers
>  >   Trond
>  >
> 
> Ah, news to me!
> 
> So if you mount a volume ro at one mount point /mnt1 and then try to 
> mount the same volume rw at a second mount point /mnt2 you'll run into 
> problems?  Apologies, didn't catch this in release notes.  Thanks!
> 
> --Greg
> 
> ---+ A New Beginning
> 
> [root@adcgar04 /]# umount -a -t nfs
> 
> [root@adcgar04 /]# mount -v | grep pandora
> 
> [root@adcgar04 /]# cat /proc/mounts | grep pandora
> 
> [root@adcgar04 /]# mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
> 
> [root@adcgar04 /]# mount -v | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (rw,addr=163.181.34.137)
> 
> [root@adcgar04 /]# cat /proc/mounts | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> rw,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> 
> [root@adcgar04 /]# touch /mnt2/asdf
> 
> ---+ The ro Strikes Back
> 
> [root@adcgar04 /]# mount -o ro 
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt1
> 
> [root@adcgar04 /]# mount -o rw 
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
> 
> [root@adcgar04 /]# mount -v | grep mnt
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt1 type nfs 
> (ro,addr=163.181.34.137)
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (rw,addr=163.181.34.137)
> 
> [root@adcgar04 /]# cat /proc/mounts | grep mnt
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt1 nfs 
> ro,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> ro,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> 
> [root@adcgar04 /]# touch /mnt2/asdf
> touch: cannot touch `/mnt2/asdf': Read-only file system
> 
> 
> 
> 
> 

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
