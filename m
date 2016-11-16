Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.dit.upm.es ([138.4.2.18]:50070 "EHLO mail3.dit.upm.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932458AbcKPSUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Nov 2016 13:20:18 -0500
Subject: Re: possible bug in nfs-kernel-server
To: Miklos Szeredi <mszeredi@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <56743FB6.80903@redhat.com> <20151218200840.GA28692@fieldses.org>
 <5677BCD4.4060009@redhat.com> <20151221164752.GA7869@fieldses.org>
 <56783DCC.1060201@redhat.com> <20151221201403.GB7869@fieldses.org>
 <2443f0d3-6937-ae92-d4d5-6e1f00a19e81@dit.upm.es>
 <20161108201611.GB26589@fieldses.org>
 <37f8eaf5-128c-ecd5-ae65-3b340c990171@dit.upm.es>
 <20161111190332.GA28132@fieldses.org> <20161111220425.GA30914@fieldses.org>
 <CAOssrKfupMvmpfk5fV1J6Hv5_FUSCjU0euGkY8aeU3kxgzEXMQ@mail.gmail.com>
Cc: Soumya Koduri <skoduri@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        administracion del centro de calculo del dit
        <cdc@dit.upm.es>
From: Omar Walid Llorente <omar@dit.upm.es>
Message-ID: <b702922d-c80c-799b-c83e-ff2d3cb74e08@dit.upm.es>
Date: Wed, 16 Nov 2016 19:19:59 +0100
MIME-Version: 1.0
In-Reply-To: <CAOssrKfupMvmpfk5fV1J6Hv5_FUSCjU0euGkY8aeU3kxgzEXMQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Miklos, thanks for your time and your work.

AFAIK, we are using the "default_permissions" fuse option, along with 
"allow_other" fuse option, among others. See the /proc/mounts of the 
glusterfs-client and nfs-server behind:

root@cuentas03-lab:/etc# cat /proc/mounts
rootfs / rootfs rw 0 0
sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,relatime,size=2012892k,nr_inodes=503223,mode=755 0 0
devpts /dev/pts devpts 
rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,noexec,relatime,size=404752k,mode=755 0 0
/dev/sda2 / ext4 rw,relatime,errors=remount-ro,data=ordered 0 0
none /sys/fs/cgroup tmpfs rw,relatime,size=4k,mode=755 0 0
none /sys/fs/fuse/connections fusectl rw,relatime 0 0
none /sys/kernel/debug debugfs rw,relatime 0 0
none /sys/kernel/security securityfs rw,relatime 0 0
none /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
none /run/shm tmpfs rw,nosuid,nodev,relatime 0 0
none /run/user tmpfs 
rw,nosuid,nodev,noexec,relatime,size=102400k,mode=755 0 0
none /sys/fs/pstore pstore rw,relatime 0 0
rpc_pipefs /run/rpc_pipefs rpc_pipefs rw,relatime 0 0
systemd /sys/fs/cgroup/systemd cgroup 
rw,nosuid,nodev,noexec,relatime,name=systemd 0 0
recipiente6hd:/home-lab-3.tcp /home-3-old fuse.glusterfs 
rw,relatime,user_id=0,group_id=0,default_permissions,allow_other,max_read=131072 
0 0
root@cuentas03-lab:/etc#

In any case, the kernel we are using (3.13.0-96-generic #143-Ubuntu SMP 
Mon Aug 29 20:15:20 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux) has fuse 
included (not as a module) so if it would be necessary to change the 
fuse mount options some help would be needed.

Would you like to have access as root to a fully functional virtual 
environment where the problem can be reproduced?

Thanks again, and if above is not possible for you, please tell us how 
we can manage to debug the issue. See at end a log of the last tests.

Omar

# At the nfs-client:

cdc@l056:~$ cat /proc/mounts | grep "/home/cdc"
cuentas03:/home-3-old/cdc /home/cdc nfs 
rw,noatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=138.4.30.18,mountvers=3,mountport=49531,mountproto=tcp,fsc,local_lock=all,addr=138.4.30.18 
0 0
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444 
444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
cp: failed to close ‘kk.txt’: Permission denied
-r--r--r-- 1 cdc admincdc 7 nov 16  2016 444.txt
-r--r--r-- 1 cdc admincdc 0 nov 16  2016 kk.txt
cdc@l056:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444 
444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
cp: failed to close ‘kk.txt’: Permission denied
-r--r--r-- 1 cdc admincdc 7 nov 16  2016 444.txt
-r--r--r-- 1 cdc admincdc 0 nov 16  2016 kk.txt
cdc@l056:~$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt; chmod 444 
444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
cp: failed to close ‘kk.txt’: Permission denied
-r--r--r-- 1 cdc admincdc 7 nov 16  2016 444.txt
-r--r--r-- 1 cdc admincdc 0 nov 16  2016 kk.txt
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$
cdc@l056:~$ sudo su
root@l056:/home/cdc# rm -f kk.txt 444.txt; echo "prueba" > 444.txt; 
chmod 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
-r--r--r-- 1 root root 7 nov 16  2016 444.txt
-r--r--r-- 1 root root 7 nov 16  2016 kk.txt
root@l056:/home/cdc# rm -f kk.txt 444.txt; echo "prueba" > 444.txt; 
chmod 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
-r--r--r-- 1 root root 7 nov 16  2016 444.txt
-r--r--r-- 1 root root 7 nov 16  2016 kk.txt
root@l056:/home/cdc# rm -f kk.txt 444.txt; echo "prueba" > 444.txt; 
chmod 444 444.txt; cp -p 444.txt kk.txt; ls -ld 444.txt kk.txt
-r--r--r-- 1 root root 7 nov 16  2016 444.txt
-r--r--r-- 1 root root 7 nov 16  2016 kk.txt
root@l056:/home/cdc# exit
cdc@l056:~$

El 15/11/16 a las 11:13, Miklos Szeredi escribió:
> On Fri, Nov 11, 2016 at 11:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> So if I'm reading right, the setup is
>>
>>          nfs client---NFSv3--->knfsd---FUSE-->gluster
>>
>> I hate to just pass the buck, but my bet is on the issue being either on
>> the gluster side, or on limitations of the fuse protocol itself.
>>
>> Cc'ing Miklos as I believe he did the original fuse nfsd export
>> implementation.  Miklos, does fuse has a way for file owners to override
>> permissions?  We need this sometimes because for example, an application
>> may hold a write open on a read-only file, but the server doesn't itself
>> already have an open (which can happen for lots of reasons).
> Is glusterfs using "default_permissions" fuse option?
>
> If so, then the above shouldn't be an issue, since permission checking
> is done by generic_permission() which works the same for all
> filesystems.
>
> If not, then there's the same problem as re-exporting NFSv4 as NFSv3
> would have: the permissions are not checked in ->permission(), but in
> e.g. ->atomic_open() so nfsd's override mechanism wouldn't work.
>
> Thanks,
> Miklos

-- 
----------------------------------------------------------------
Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
Tel:(+34) 915495762-Ext.3005
Tel:(+34) 913367366-Ext.3005
----------------------------------------------------------------

