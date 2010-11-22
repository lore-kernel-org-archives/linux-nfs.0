From: Hiroyuki Sato <hiroysato@gmail.com>
Subject: Re: [Q] I tried to mount nfs_server:/mnt volume, but It mounted
 another volume.
Date: Mon, 22 Nov 2010 09:21:27 +0900
Message-ID: <AANLkTinUNioqfwL_Yx6Ryynq-tZ3SJRsA-pW-scTmXj6@mail.gmail.com>
References: <AANLkTi=vpRm3MEiQZ39bw5XwfjL6CVbGEkAKWz-ynEp_@mail.gmail.com>
	<4CE9217E.6090002@panasas.com>
	<20101121224154.GA11043@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-rdma-owner@vger.kernel.org>
In-Reply-To: <20101121224154.GA11043@fieldses.org>
Sender: linux-rdma-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you useful information. I'll study about NFSv4

--
Hiroyuki Sato

2010/11/22 J. Bruce Fields <bfields@fieldses.org>:
> On Sun, Nov 21, 2010 at 03:41:18PM +0200, Boaz Harrosh wrote:
>> On 11/21/2010 02:23 PM, Hiroyuki Sato wrote:
>> > Hello lists
>> >
>> > OS: CentOS 5.5
>> > kernel: 2.6.36 rebuild myself.
>> >
>> >
>> > =A0 I'm trying to test NFS/RDMA.
>> > =A0 I tried to mount nfs_server:/mnt volume on on nfs_client
>> > =A0 but It mounted nfs_server:/nfstest volume
>> >
>> > =A0 note: /nfstest is tmpfs
>> >
>> > =A0this is mount output
>> > =A0 =A0 tmpfs on /nfstest type tmpfs (rw,size=3D4g)
>> > =A0 =A0 /dev/sdb1 on /mnt type ext3 (rw)
>> >
>> > =A0 Is this bug??
>> >
>> > NFS server config
>> >
>> > =A0 # ls -1 /mnt
>> > =A0 This_is_mnt_volume
>> >
>> > =A0 # ls -1 /nfstest
>> > =A0 This_is_nfstest_volume
>> >
>> > =A0 # cat /etc/exports
>> > =A0 /nfstest =A0 192.168.100.0/255.255.255.0(fsid=3D0,rw,async,ins=
ecure,no_root_squash)
>> > =A0 /mnt =A0 =A0 =A0 192.168.100.0/255.255.255.0(fsid=3D0,rw,async=
,insecure,no_root_squash)
>> >
>>
>> You must not have two exports with fsid=3D0. First one is picked.
>>
>> nfs4 will only export a single name space point, other exports are
>> subdirs of that root export. (use bind mounts to present a single
>> directory tree)
>>
>> <http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html>
>
> We should update and/or replace that documentation; with new nfs-util=
s
> and kernel, if you omit the "fsid=3D0", you'll end up with an nfsv4
> namespace that's the same as v2/v3's always was.
>
> --b.
>
>>
>> NFSv4 exports on linux
>> ~~~~~~~~~~~~~~~~~~~~~~
>>
>> NFSv4 no longer has a separate "mount" protocol. Instead of exportin=
g a number of distinct exports, an NFSv4 client sees the NFSv4 server's=
 exports as existing inside a single filesystem, called the nfsv4 "pseu=
dofilesystem".
>>
>> On the current linux implementation, the pseudofilesystem is a singl=
e real filesystem, identified at export with the fsid=3D0 option.
>>
>> In the example above, we exported only a single filesystem, which th=
e client mounted as "/". You can provide clients with multiple filesyst=
ems to mount, producing NFSv3-like-behavior, by creative use of mount -=
-bind. For example, you could export /usr/local/bin to clients as /bin =
and /usr/local/etc as /etc as follows:
>>
>> mkdir /export
>> mkdir /export/bin
>> mkdir /export/etc
>> mount --bind /usr/local/bin /export/bin
>> mount --bind /usr/local/etc /export/etc
>> exportfs -ofsid=3D0,insecure,no_subtree_check *:/export
>> exportfs -orw,nohide,insecure,no_subtree_check *:/export/bin
>> exportfs -orw,nohide,insecure,no_subtree_check *:/export/etc
>>
>> Note that the paths returned by the "showmount" program are meaningf=
ul only to clients using nfs versions 2 and 3; in the above example, "s=
howmount" will list the paths /export, /export/bin/, and /export/etc, b=
ut nfsv4 clients should mount yourserver:/, yourserver:/bin, or yourser=
ver:/etc.
>>
>> </http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html>
>>
>> Boaz
>> >
>> > =A0 # modprobe svcrdma
>> >
>> > =A0 # /sbin/service nfs start
>> >
>> > =A0 # echo rdma 20049 > /proc/fs/nfsd/portlist
>> >
>> >
>> > Client Setting
>> >
>> > =A0 /sbin/modprobe xprtrdma
>> > =A0 /sbin/mount.rnfs 192.168.100.231:/mnt /mnt -i -o rdma,port=3D2=
0049
>> >
>> > =A0 # ls -1 /mnt
>> > =A0 This_is_nfstest_volume
>> >
>> > NFS Server log
>> > =A0 sysctl -w sunrpc.nfsd_debug=3D1023
>> >
>> > =A0 Nov 21 20:47:37 dell1435 mountd[3575]: authenticated mount req=
uest
>> > from 192.168.100.232:766 for /mnt (/mnt)
>> > =A0 Nov 21 20:47:37 dell1435 mountd[3575]: /nfstest and /mnt have =
same
>> > filehandle for 192.168.100.0/255.255.255.0, using first
>> > =A0 Nov 21 20:48:55 dell1435 mountd[3575]: authenticated unmount r=
equest
>> > from 192.168.100.232:912 for /mnt (/mnt)
>> > =A0 Nov 21 20:48:55 dell1435 mountd[3575]: authenticated unmount r=
equest
>> > from 192.168.100.232:913 for /mnt (/mnt)
>> > =A0 Nov 21 20:49:00 dell1435 mountd[3575]: authenticated unmount r=
equest
>> > from 192.168.100.232:917 for /mnt (/mnt)
>> > =A0 Nov 21 20:49:16 dell1435 mountd[3575]: authenticated mount req=
uest
>> > from 192.168.100.232:865 for /mnt (/mnt)
>> > =A0 Nov 21 21:02:22 dell1435 mountd[3575]: authenticated unmount r=
equest
>> > from 192.168.100.232:955 for /mnt (/mnt)
>> > =A0 Nov 21 21:02:26 dell1435 mountd[3575]: authenticated mount req=
uest
>> > from 192.168.100.232:884 for /mnt (/mnt)
>> > =A0 Nov 21 21:02:26 dell1435 kernel: nfsd: exp_rootfh(/mnt
>> > [ffff88011f586740] 192.168.100.0/255.255.255.0:sdb1/2)
>> >
>> >
>> > --
>> > Hiroyuki Sato
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
