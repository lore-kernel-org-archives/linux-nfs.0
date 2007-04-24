From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 24 Apr 2007 17:01:57 -0500
Message-ID: <462E7E55.5040202@amd.com>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com> <462CFC92.2080201@amd.com>
	<462E6131.7050504@amd.com>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgT66-000671-Ua
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 15:02:55 -0700
Received: from outbound-fra.frontbridge.com ([62.209.45.174]
	helo=outbound4-fra-R.bigfish.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgT68-0001ZS-Ad
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 15:02:57 -0700
In-Reply-To: <462E6131.7050504@amd.com>
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


Ignore this email; my foolish use of

[root@adcgar04 tmp]# mount -v | grep pandora
[root@adcgar04 tmp]# cat /proc/mounts | grep pandora

and

[root@adcgar04 tmp]# umount -a -t nfs

make the captured session useless in debugging (as I cannot reproduce 
the behavior).

Sorry everyone!

--Greg


Gregory Baker wrote:
> 
> Gregory Baker wrote:
> 
>> So the deal is, the mount flags (and NFS options) are set only the first 
>> time that a given combination of server and filesystem are mounted. If 
>> you ever mount the same filesystem from the same server on another 
>> mountpoint, you'll get the flags and options that were passed on to the 
>> first mount. There's no working around that.
>> *****
> 
> Should these mount flags (and NFS options) expire/be removed from some 
> table somewhere when you unmount/remount the filesystem?  The mount 
> flags (and NFS options) persist between complete unmounting / remounting 
> of said filesystem.
> 
> [greg@apathy 115656]$ cat typescript
> 
> * Look at me.  Don't have anything mounted via NFS yet the mount
> * gets stuck as ro when mounted...
> 
> [root@adcgar04 tmp]# umount -a -t nfs
> [root@adcgar04 tmp]# mount -v | grep pandora
> [root@adcgar04 tmp]# cat /proc/mounts | grep pandora
> [root@adcgar04 tmp]# mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
> [root@adcgar04 tmp]# mount -v | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (rw,addr=163.181.34.137)
> [root@adcgar04 tmp]# cat /proc/mounts | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> [root@adcgar04 tmp]# touch /mnt2/asdf
> touch: cannot touch `/mnt2/asdf': Read-only file system
> 
> * OK, let's try this fancy mount command..
> 
> [root@adcgar04 tmp]# mount -o remount,rw /mnt2
> [root@adcgar04 tmp]#  mount -v | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (rw,remount,addr=163.181.34.137)
> [root@adcgar04 tmp]#  cat /proc/mounts | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> rw,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> 
> * Everybody is happy!
> 
> [root@adcgar04 tmp]#  touch /mnt2/asdf
> 
> * Let's get rid of NFS mount and see what happens now
> 
> [root@adcgar04 tmp]# umount /mnt2
> [root@adcgar04 tmp]#  mount -v | grep pandora
> [root@adcgar04 tmp]#  cat /proc/mounts | grep pandora
> [root@adcgar04 tmp]#  mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
> [root@adcgar04 tmp]# mount -v | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (rw,addr=163.181.34.137)
> [root@adcgar04 tmp]# cat /proc/mounts | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> rw,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> 
> * Everybody is happy!
> 
> [root@adcgar04 tmp]# touch /mnt2/asdf
> 
> * Let's give "something" the notion that this is a ro mount...
> 
> [root@adcgar04 tmp]# mount -o remount,ro /mnt2
> [root@adcgar04 tmp]#  mount -v | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (ro,remount,addr=163.181.34.137)
> [root@adcgar04 tmp]#  cat /proc/mounts | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> 
> * RO (expected)
> 
> [root@adcgar04 tmp]# touch /mnt2/asdf
> touch: cannot touch `/mnt2/asdf': Read-only file system
> 
> * OK, unmount NFS mount, try again
> 
> [root@adcgar04 tmp]#  umount /mnt2
> [root@adcgar04 tmp]#  mount -v | grep pandora
> [root@adcgar04 tmp]#  cat /proc/mounts | grep pandora
> [root@adcgar04 tmp]#  mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
> [root@adcgar04 tmp]#  mount -v | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
> (rw,addr=163.181.34.137)
> [root@adcgar04 tmp]#  cat /proc/mounts | grep pandora
> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
> ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
> 0 0
> 
> * Boo-RO/RW (unexpected)
> 
> [root@adcgar04 tmp]#  touch /mnt2/asdf
> touch: cannot touch `/mnt2/asdf': Read-only file system
> [root@adcgar04 tmp]# exit
> 
> * So it seems that something remembers the last mount permissions, even
> * though mount -v and /proc/mount do not show a filesystem mounted.
> * The permissions persist to be associated with the exported filesystem.
> * What causes this?  Note: it's not the automounter process; this was
> * stopped during testing.
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
