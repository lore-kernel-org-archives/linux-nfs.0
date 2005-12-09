From: Wilhelm Meier <meier@informatik.fh-kl.de>
Subject: UnionFS over NFS over UnionFS
Date: Sat, 10 Dec 2005 00:20:26 +0100
Message-ID: <200512100020.26498.meier@informatik.fh-kl.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ekpgy-0001U8-Jl
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 13:22:12 -0800
Received: from natfrord.rzone.de ([81.169.145.161])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ekpgw-0002TZ-U4
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 13:22:12 -0800
Received: from [192.168.1.13] (p54A59284.dip0.t-ipconnect.de [84.165.146.132])
	by post.webmailer.de (8.13.1/8.13.1) with ESMTP id jB9LLlQg012683
	for <nfs@lists.sourceforge.net>; Fri, 9 Dec 2005 22:22:07 +0100 (MET)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hello everybody,

the below problem was allready posted to the unionfs-list, but remains=20
unsolved:
=2D-------------

To clarify things further, this happens only in the follwing scenario (as
described in previous posting, see below):

1) we build a union mounted on server:/tftproot/gentoo_B
2) we export this union via NFS
3) we mount server:/tftproot/gentoo_B onto client:/mnt/test/N
4) we build a union on the client consisting of /mnt/test/N an some tmpfs

If we change step 2) to export some local filesytem (tftproot/gentoo_A in
the below example) and change step 3) to mount server:/tftproot/gentoo_A
onto the client, all works well.

A saw a posting on this list reporting similar problems. Are the any hints?

=2D-
Wilhelm


> Hello,
>
> thank you for the advice, but this does not solve the problem.
>
> On the other hand, I tried to export and nfs-mount all rw, but to declare
> the nfs-mounted branch ro for the union-mount:
>
> gs test # mount
> /dev/hda1 on / type ext3 (rw,noatime)
> proc on /proc type proc (rw)
> sysfs on /sys type sysfs (rw)
> udev on /dev type tmpfs (rw,nosuid)
> devpts on /dev/pts type devpts (rw)
> /dev/hdb1 on /tftproot type ext3 (rw,noatime)
> none on /tftproot/gentoo_B type unionfs
> (rw,dirs=3D/tftproot/gentoo_Bdiff=3Drw:/tftproot/gentoo_A=3Dro)
> shm on /dev/shm type tmpfs (rw,noexec,nosuid,nodev)
> nfsd on /proc/fs/nfs type nfsd (rw)
> rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
> 192.168.39.10:/tftproot/gentoo_B on /mnt/test/N type nfs
> (rw,addr=3D192.168.39.10)
> none on /mnt/test/T type tmpfs (rw)
> none on /mnt/test/A type unionfs (rw,dirs=3D/mnt/test/T=3Drw:/mnt/test/N=
=3Dro)
>
> gs test # touch A/x
> touch: setting times of `A/x': Operation not permitted
>
> gs test # ls A
> bin =A0 dev =A0home =A0mnt =A0proc =A0sbin =A0 =A0 =A0 =A0 =A0sys =A0usr
> boot =A0etc =A0lib =A0 opt =A0root =A0stateless.sh =A0tmp =A0var
>
> gs test # touch N/x
>
> gs test # ls A
> bin =A0 dev =A0home =A0mnt =A0proc =A0sbin =A0 =A0 =A0 =A0 =A0sys =A0usr =
=A0x
> boot =A0etc =A0lib =A0 opt =A0root =A0stateless.sh =A0tmp =A0var
>
> gs test # touch A/x
> touch: setting times of `A/x': Operation not permitted
> gs test #
>
> Any hints?
>
> -
> Wilhelm
>>
>> Hi!!
>>
>>> The same problem arises also a simpler setup (on the a single machine):
>>>
>>> gs ~ # mount
>>> /dev/hda1 on / type ext3 (rw,noatime)
>>> proc on /proc type proc (rw)
>>> sysfs on /sys type sysfs (rw)
>>> udev on /dev type tmpfs (rw,nosuid)
>>> devpts on /dev/pts type devpts (rw)
>>> /dev/hdb1 on /tftproot type ext3 (rw,noatime)
>>> shm on /dev/shm type tmpfs (rw,noexec,nosuid,nodev)
>>> nfsd on /proc/fs/nfs type nfsd (rw)
>>> /dev/hdc on /mnt/cdrom type iso9660 (ro)
>>> none on /tftproot/gentoo_B type unionfs
>>> (rw,dirs=3D/tftproot/gentoo_Bdiff=3Drw:/tftproot/gentoo_A=3Dro)
>>> rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
>>> 192.168.39.10:/tftproot/gentoo_B on /mnt/test/N type nfs
>>> (rw,addr=3D192.168.39.10)
>>
>> If this share is exported RO it should be mounted RO only. Unfortunately
>> I
>> may mount a RO nfs share with RW option on a client (of course it does
>> not
>> renders the share writeable) - but it will confuse unionfs. If you mount
>> your share explicitly RO you shouldn't get a permission denied...
>>
>> We had the same problem with RO nfs root filesystem unioned with RW
>> tempfs
>> on top of it. Hope I got the idea right what you intend to do :-))
>>
>> Ciao,
>> =A0=A0=A0=A0=A0Dirk
>>
>>> none on /mnt/test/T type tmpfs (rw)
>>> none on /mnt/test/A type unionfs
>>> (rw,dirs=3D/mnt/test/T=3Drw:/mnt/test/N=3Dro)
>>> gs ~ #
>>>
>>> As you see 192.168.39.10:/tftproot/gentoo_B is exported and mounted
>>> on /mnt/test/N. This is union-mounted together with tmpfs /mnt/test/T
>>> on /mnt/test/A.
>>>
>>> On /mnt/test/A we get:
>>>
>>> gs A # touch x
>>> touch: setting times of `x': Operation not permitted
>>>
>>>
>>> Am Montag, 5. Dezember 2005 13:48 schrieben Sie:
>>> > >NFS: Buggy server - nlink =3D=3D 0!
>>> > >nfs_fhget: iget failed
>>> > >
>>> > >We are using unionfs-1.0.14
>>> >
>>> > Step 1: Try updating to 1.1.1 or some CVS snapshot.
>>> >
>>> >
>>> >
>>> >
>>> > Jan Engelhardt
>>>
>>> --
>>> --
>>> Wilhelm Meier
>>> email: meier@informatik.fh-kl.de
>>> _______________________________________________
>>> unionfs mailing list
>>> unionfs@mail.fsl.cs.sunysb.edu
>>> http://www.fsl.cs.sunysb.edu/mailman/listinfo/unionfs
>>>
>>
>
>
>
=2D-=20
=2D-
Wilhelm Meier
email: meier@informatik.fh-kl.de


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
