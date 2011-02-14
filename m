Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:32043 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202Ab1BNP6I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 10:58:08 -0500
Subject: Re: NFS only mount with -o udp option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTimiACttSQ+=M0UNGs5nZrP=zs0zRFV+4HP8c-OP@mail.gmail.com>
Date: Mon, 14 Feb 2011 10:56:42 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <81853901-909D-4803-81A5-C01C0337CAE1@oracle.com>
References: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com> <665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com> <AANLkTi=dgyOmf+to8waRi+piomovMM-H7_7GdzyhYuEo@mail.gmail.com> <0F40C51E-38A3-451B-9D88-586CFD82EF8F@oracle.com> <AANLkTiksVebz5Pc+hH55hRUgvQ5PMFE1DG2X1JWbtSeD@mail.gmail.com> <AANLkTinG0774DoYyM+2381Eyxdx0+29JUs_-dzfRp=vM@mail.gmail.com> <1A31AB06-8518-427C-8D0B-0058AA613D0E@oracle.com> <AANLkTimiACttSQ+=M0UNGs5nZrP=zs0zRFV+4HP8c-OP@mail.gmail.com>
To: Edgar Almonte <samudhio@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Edgar-

On Feb 11, 2011, at 6:46 PM, Edgar Almonte wrote:

> hmm i will try update to the last version but is the lasted in
> official repository of my distro

Yes, that could be a problem.  Out of curiosity, can you tell us what version of nfs-utils is running on the working Debian client you have?

> the rpcinfo -p localhost output ( run at the server )
> 
> rpcinfo -p localhost
>   program vers proto   port  service
>    100000    4   tcp    111  portmapper
>    100000    3   tcp    111  portmapper
>    100000    2   tcp    111  portmapper
>    100000    4   udp    111  portmapper
>    100000    3   udp    111  portmapper
>    100000    2   udp    111  portmapper
>    391002    2   tcp    661  sgi_fam
>    100024    1   udp  49216  status
>    100024    1   tcp  42903  status
>    100003    2   tcp   2049  nfs
>    100003    3   tcp   2049  nfs
>    100003    4   tcp   2049  nfs
>    100227    2   tcp   2049  nfs_acl
>    100227    3   tcp   2049  nfs_acl
>    100003    2   udp   2049  nfs
>    100003    3   udp   2049  nfs
>    100003    4   udp   2049  nfs
>    100227    2   udp   2049  nfs_acl
>    100227    3   udp   2049  nfs_acl
>    100021    1   udp  36092  nlockmgr
>    100021    3   udp  36092  nlockmgr
>    100021    4   udp  36092  nlockmgr
>    100021    1   tcp  52268  nlockmgr
>    100021    3   tcp  52268  nlockmgr
>    100021    4   tcp  52268  nlockmgr
>    100005    3   udp  41849  mountd
>    100005    3   tcp  46012  mountd

This looks weird.  NFS is available on TCP and UDP in all three versions, but MNT is available in version 3.  I wonder if this is confusing mount.nfs.  Is there any reason why your server is configured to disable MNT version 1?

> On Fri, Feb 11, 2011 at 7:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Feb 11, 2011, at 6:13 PM, Edgar Almonte wrote:
>> 
>>> Was a ipv6 issues because i add this to the client with the problem:
>>> options ipv6 disable=1
>>> in /etc/modprobe.d/modprobe.conf
>>> reboot and mount without using udp option work, output:
>>> 
>>> [root@circle zen]# mount heaven.local:/STORAGE /nfs/STORAGE/ -v
>>> mount: no type was given - I'll assume nfs because of the colon
>>> mount.nfs: timeout set for Fri Feb 11 19:11:53 2011
>>> mount.nfs: trying text-based options
>>> 'vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
>>> mount.nfs: mount(2): No such file or directory
>>> mount.nfs: trying text-based options 'addr=192.168.1.102'
>>> mount.nfs: prog 100003, trying vers=3, prot=6
>>> mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot TCP port 2049
>>> mount.nfs: prog 100005, trying vers=3, prot=17
>>> mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41849
>>> 
>>> and i think maybe is a bug of nfs-utils that can't handle in the
>>> proper way this because a connection using ipv4 protocol exist ( even
>>> it detect it )
>>> 
>>> should i need report something like this ? or and wrong ?
>> 
>> I swear this has been discussed and fixed already, but I can't find a specific fix in the bugzilla database or the git log.  nfs-utils 1.2.2 is at least a year old.  Can you update to the latest version and try again?
>> 
>> Also, please report the NFS server's transport capabilities.  "rpcinfo 192.168.1.102" should work.  You may need the "-p" option.
>> 
>>> On Fri, Feb 11, 2011 at 6:57 PM, Edgar Almonte <samudhio@gmail.com> wrote:
>>>> [root@circle zen]# pacman -Qs nfs-utils
>>>> local/nfs-utils 1.2.2-4 [0.69 MB]
>>>>    Support programs for Network File Systems
>>>> [root@circle zen]# uname -a
>>>> Linux circle 2.6.36-ARCH #1 SMP PREEMPT Mon Jan 24 18:34:55 UTC 2011
>>>> i686 Intel(R) Atom(TM) CPU D510 @ 1.66GHz GenuineIntel GNU/Linux
>>>> 
>>>> 
>>>> On Fri, Feb 11, 2011 at 1:40 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>> Which nfs-utils version and kernel release are you using?  What transport protocols are available from your NFS server?  It looks like only UDP.  I recall a bug fix in this area in the past year.
>>>>> 
>>>>> On Feb 11, 2011, at 12:35 PM, Edgar Almonte wrote:
>>>>> 
>>>>>> i get this without udp option:
>>>>>> 
>>>>>> mount: no type was given - I'll assume nfs because of the colon
>>>>>> mount.nfs: timeout set for Fri Feb 11 13:27:33 2011
>>>>>> mount.nfs: trying text-based options
>>>>>> 'vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
>>>>>> mount.nfs: mount(2): No such file or directory
>>>>>> mount.nfs: trying text-based options
>>>>>> 'vers=4,addr=fe80::224:21ff:fe57:368d,clientaddr=::'
>>>>>> mount.nfs: mount(2): Input/output error
>>>>>> mount.nfs: mount system call failed
>>>>>> 
>>>>>> 
>>>>>> and with udp option:
>>>>>> 
>>>>>> ount: no type was given - I'll assume nfs because of the colon
>>>>>> mount.nfs: timeout set for Fri Feb 11 13:28:29 2011
>>>>>> mount.nfs: trying text-based options
>>>>>> 'udp,vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
>>>>>> mount.nfs: mount(2): No such file or directory
>>>>>> mount.nfs: trying text-based options 'udp,addr=192.168.1.102'
>>>>>> mount.nfs: prog 100003, trying vers=3, prot=17
>>>>>> mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot UDP port 2049
>>>>>> mount.nfs: prog 100005, trying vers=3, prot=17
>>>>>> mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41044
>>>>>> heaven.local:/STORAGE on /nfs/STORAGE type nfs (rw,udp)
>>>>>> 
>>>>>> 
>>>>>> for other distro ( debian laptop ) without the udp option:
>>>>>> 
>>>>>> mount: no type was given - I'll assume nfs because of the colon
>>>>>> mount.nfs: timeout set for Fri Feb 11 13:31:37 2011
>>>>>> mount.nfs: trying text-based options
>>>>>> 'vers=4,addr=192.168.1.102,clientaddr=192.168.1.107'
>>>>>> mount.nfs: mount(2): No such file or directory
>>>>>> mount.nfs: trying text-based options 'addr=192.168.1.102'
>>>>>> mount.nfs: prog 100003, trying vers=3, prot=6
>>>>>> mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot TCP port 2049
>>>>>> mount.nfs: prog 100005, trying vers=3, prot=17
>>>>>> mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41044
>>>>>> heaven.local:/STORAGE on /srv/nfs type nfs (rw)
>>>>>> 
>>>>>> 
>>>>>> and look like is some ipv6 issues
>>>>>> 
>>>>>> 
>>>>>> On Thu, Feb 10, 2011 at 11:50 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>> 
>>>>>>> On Feb 9, 2011, at 7:59 PM, Edgar Almonte wrote:
>>>>>>> 
>>>>>>>> hello list
>>>>>>>> 
>>>>>>>> like the subject say after some upgrade of my distro ( i have 2
>>>>>>>> machine with the same distro and only in one happne the problem ) i
>>>>>>>> can only mount nfs share using the option -o udp , without it i get
>>>>>>>> this error
>>>>>>>> mount.nfs: mount system call failed
>>>>>>> 
>>>>>>> What does
>>>>>>> 
>>>>>>>  sudo mount.nfs heaven.local:/STORAGE /nfs/STORAGE -v
>>>>>>> 
>>>>>>> say?  It should tell you how the mount command is negotiating with the server.
>>>>>>> 
>>>>>>>> i am using avahi-dns ( mdns ) for hostname resolve
>>>>>>>> 
>>>>>>>> command used:
>>>>>>>> mount heaven.local:/STORAGE /nfs/STORAGE/
>>>>>>>> check dns is work right :
>>>>>>>> 
>>>>>>>> ping heaven.local
>>>>>>>> PING heaven.local (192.168.1.102) 56(84) bytes of data.
>>>>>>>> 64 bytes from heaven.local (192.168.1.102): icmp_seq=1 ttl=64 time=0.153 ms
>>>>>>>> 64 bytes from heaven.local (192.168.1.102): icmp_seq=2 ttl=64 time=0.160 ms
>>>>>>>> ^C
>>>>>>>> --- heaven.local ping statistics ---
>>>>>>>> 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
>>>>>>>> rtt min/avg/max/mdev = 0.153/0.156/0.160/0.013 ms
>>>>>>>> 
>>>>>>>> 
>>>>>>>> anyidea what i need check for solve this issue ?
>>>>>>>> 
>>>>>>>> thanks
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>> 
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>> 
>>>>> --
>>>>> Chuck Lever
>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>> 
>>>>> 
>>>>> 
>>>>> 
>>>>> 
>>>> 
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




