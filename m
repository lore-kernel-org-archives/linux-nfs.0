From: "John Roberts" <john_roberts@credence.com>
Subject: Re: Linux NFS writes to Solaris very, very slow
Date: Fri, 23 Jul 2004 10:04:21 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407231704.i6NH4LV21216@algebra.hillsboro.credence.com>
Reply-To: John Roberts <john_roberts@credence.com>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Cc: john_roberts@credence.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bo3T7-00061T-Iw
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 10:04:25 -0700
Received: from hifw1.credence.com ([63.127.103.172] helo=hinscp.hillsboro.credence.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bo3T7-0000xN-4M
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 10:04:25 -0700
To: nfs@lists.sourceforge.net
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



>On Fri, Jul 23, 2004 at 09:20:34AM -0700, John Roberts wrote:
>> What we've observed is that NFS writes from our Linux boxes to
>> the Solaris server (and other Solaris workstations) is _very_
>> slow.  Reads seem to be operating at a reasonable speed.
>> FTP speeds are blazing (protocol below NFS).
>
>What are your mount options? you should be using nfsv3; v2 is
>of course terribly slow on writes.

Our Solaris server is orfsrv2, which is mounted via
autofs and "mount" returns:

orfsrv2:/export/vol/ims/apps/xemacs/2.4.21-4.0.1.EL on /opt2/xemacs type nfs 
(rw,addr=10.4.10.154)
orfsrv2:/export/vol/engr/cobalt on /ims/cobalt type nfs (rw,tcp,addr=10.4.10.154)
orfsrv2:/export/vol/engr/viper on /ims/viper type nfs (rw,addr=10.4.10.154)

Full mount list at end of this email/post, along with /etc/fstab.

I believe that we are using nfsv3.  How can I tell?
When I use your wonderful nfsstat utility it reports only
Client nfs v3 stats (although it gives both Server nfs v2
and Server nfs v3 stats).

Our distro is Redhat Enterprise Linux 3 (2.4.21-4.0.1.EL #1).

As for the Solaris server, its running Solaris 2.8.
I would assume that's nfsv3.  If I run nfsstat on another Sun
(solaris 2.8) workstation, it reports back fileserver
statistics like:

/usr/local from orfsrv2:/export/vol/ims/apps/local/5.8
 Flags:         
vers=3,proto=tcp,sec=sys,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retra
ns=5,timeo=600
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60



>> On a completely seperate note, Linux-to-Linux NFS file writes
>> only seem to be fast if we publish the serving Linux volume
>> as asynchronous (default setting is synchronous which is slow).
>
>as long as your client uses nfsv2, that is to be expected. In
>NFSv2 the (mandated) default is to use sync mode, i.e. write
>each and every blob of data to disk before acknowledging the
>RPC operation.

So are you saying nfsv3 defaults to async?



Thanks for the reply!


John Roberts
john_roberts@credence.com

--------------------------mount output----------------------------
/dev/sda3 on / type ext3 (rw)
none on /proc type proc (rw)
usbdevfs on /proc/bus/usb type usbdevfs (rw)
/dev/sda1 on /boot type ext3 (rw)
none on /dev/pts type devpts (rw,gid=5,mode=620)
/dev/sda7 on /export type ext3 (rw)
/dev/sda2 on /export/home type ext3 (rw)
none on /dev/shm type tmpfs (rw)
/dev/sda5 on /var type ext3 (rw)
automount(pid2825) on /hosts type autofs 
(rw,fd=5,pgrp=2825,minproto=2,maxproto=4)
automount(pid2807) on /csc/dept type autofs 
(rw,fd=5,pgrp=2807,minproto=2,maxproto=4)
automount(pid2777) on /csc/viewstorage type autofs 
(rw,fd=5,pgrp=2777,minproto=2,maxproto=4)
automount(pid2784) on /csc/vobs type autofs 
(rw,fd=5,pgrp=2784,minproto=2,maxproto=4)
automount(pid2786) on /csc/proj type autofs 
(rw,fd=5,pgrp=2786,minproto=2,maxproto=4)
automount(pid2782) on /csc/tools type autofs 
(rw,fd=5,pgrp=2782,minproto=2,maxproto=4)
automount(pid2890) on /home type autofs (rw,fd=5,pgrp=2890,minproto=2,maxproto=4)
automount(pid2886) on /opt2 type autofs (rw,fd=5,pgrp=2886,minproto=2,maxproto=4)
automount(pid2991) on /u type autofs (rw,fd=5,pgrp=2991,minproto=2,maxproto=4)
automount(pid2981) on /et type autofs (rw,fd=5,pgrp=2981,minproto=2,maxproto=4)
automount(pid2929) on /mfg type autofs (rw,fd=5,pgrp=2929,minproto=2,maxproto=4)
automount(pid2979) on /ims type autofs (rw,fd=5,pgrp=2979,minproto=2,maxproto=4)
automount(pid2927) on /net type autofs (rw,fd=5,pgrp=2927,minproto=2,maxproto=4)
algebra.hillsboro.credence.com:/export/home/jroberts on /u/jroberts type nfs 
(rw,nosuid,tcp,soft,addr=10.4.13.147)
algebra.hillsboro.credence.com:/export/home/jroberts on /home/jroberts type nfs 
(rw,nosuid,tcp,soft,addr=10.4.13.147)
orfsrv2:/export/vol/ims/apps/xemacs/2.4.21-4.0.1.EL on /opt2/xemacs type nfs 
(rw,addr=10.4.10.154)
orfsrv2:/export/vol/engr/cobalt on /ims/cobalt type nfs (rw,tcp,addr=10.4.10.154)
orfsrv2:/export/vol/engr/viper on /ims/viper type nfs (rw,addr=10.4.10.154)


---------------------------/etc/fstab-------------------------------------
LABEL=/                 /                       ext3    defaults        1 1
LABEL=/boot             /boot                   ext3    defaults        1 2
none                    /dev/pts                devpts  gid=5,mode=620  0 0
LABEL=/export           /export                 ext3    defaults        1 2
LABEL=/export/home      /export/home            ext3    defaults        1 2
none                    /proc                   proc    defaults        0 0
none                    /dev/shm                tmpfs   defaults        0 0
LABEL=/var              /var                    ext3    defaults        1 2
/dev/sda6               swap                    swap    defaults        0 0
/dev/cdrom              /mnt/cdrom              udf,iso9660 noauto,owner,kudzu,ro 
0 0
/dev/fd0                /mnt/floppy             auto    noauto,owner,kudzu 0 0




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
