Return-Path: <orion@nwra.com>
Subject: Re: NFS troubles
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
 Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
 <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
 <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
 <7A560163-BA54-4051-9BB4-12087952987D@oracle.com>
From: Orion Poplawski <orion@nwra.com>
Message-ID: <e1d10240-31a6-af26-d71c-df96d0c19829@nwra.com>
Date: Fri, 6 Apr 2018 16:05:48 -0600
MIME-Version: 1.0
In-Reply-To: <7A560163-BA54-4051-9BB4-12087952987D@oracle.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

On 04/06/2018 10:24 AM, Chuck Lever wrote:
> 
> 
>> On Apr 6, 2018, at 12:07 PM, Orion Poplawski <orion@nwra.com> wrote:
>>
>> On 04/03/2018 09:44 AM, Orion Poplawski wrote:
>>> Kernel is 3.10.0-693.21.1.el7.x86_64  I don't have Red Hat support for these
>>> systems.
>>>
>>> I discovered that I'd been forcing vers=4.0 mounts in order to work around a
>>> mounting issue.  
>>
>> And I'm back to seeing the mount issue at boot.  Here's the situation - we're
>> forcing kerberos on the public network, but allowing sec=sys on some private
>> networks:
>>
>> /etc/exports:
>> /               -ro,async,fsid=0 192.168.1.0/24(sec=sys)
>> 192.168.2.0/24(sec=sys) *.nwra.com(sec=krb5)
>> /export/home    -rw,async,nohide 192.168.1.0/24(sec=sys)
>> 192.168.2.0/24(sec=sys) *.nwra.com(sec=krb5)
>>
>> So for a while after boot, attempts to mount with sec=sys fail:
>>
>> # mount -t nfs4 -s -o
>> sec=sys,intr,rsize=262144,wsize=262144,noatime,lookupcache=positive,actimeo=1
>> earthib.cora.nwra.com:/export/home/greg /mnt
>> mount.nfs4: Operation not permitted
>>
>> But then later they work:
>>
>> # mount -t nfs4 -s -o
>> sec=sys,intr,rsize=262144,wsize=262144,noatime,lookupcache=positive,actimeo=1
>> earthib.cora.nwra.com:/export/home/greg /mnt
>> # umount /mnt
>>
>> This can cycle back and forth.
>>
>> I've attached a packet capture of some failed mount attempts.  It seems that
>> even with specifying sec=sys, some kerberos stuff is going on.
>>
>> It appears to be related to mounting a different sec=krb5 mount over the
>> public network from the same server.  While that mount is active, the sec=sys
>> mounts fail.  When it is unmounted, they work.  At least now I think I can
>> work around this...
> 
> For NFSv4, the client is going to use krb5i to do lease management even
> on sec=sys mounts. An NFSv4 server has to know for sure when it is talking
> to the same client on different network interfaces or with different
> security flavors. Thus the client has to use the same security flavor for
> lease management on all of its mounts of that server. That's not controlled
> by the sec= mount option.
> 
> I assume that "but then later" lasts only a few multiples of the server's
> lease time (90 seconds by default)?
> 
> Clients that use only the private network interface should be able to use
> sec=sys. But clients that use both the public and private interfaces should
> need to use sec=krb5 on both.

Testing again with RHEL 7.5 beta:
3.10.0-830.el7.x86_64
nfs-utils-1.3.0-0.52.el7.x86_64

Near as I can tell, with NFS version 4.1 mounts, as long as there is an active
sec=krb5 mount to a server, sec=sys mounts to that server fail (with the above
/etc/exports).  As soon as I unmount the sec=krb5 mount, the sec=sys mount
works.  And vice-versa - an active sec=sys mount prevents sec=krb5 mounts.
Waiting does not appear to help.  The sporadic behavior noted before was due
to the use of the automounter - as mounts came and went different ones would
break.

If I use NFS version 4.0, I can have both.  But then I get the locking bug in
my original post.

-- 
Orion Poplawski
Manager of NWRA Technical Systems          720-772-5637
NWRA, Boulder/CoRA Office             FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                 https://www.nwra.com/
