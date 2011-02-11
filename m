Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:65358 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758291Ab1BKW5F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Feb 2011 17:57:05 -0500
Received: by yib18 with SMTP id 18so1291432yib.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 14:57:04 -0800 (PST)
In-Reply-To: <0F40C51E-38A3-451B-9D88-586CFD82EF8F@oracle.com>
References: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com>
	<665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com>
	<AANLkTi=dgyOmf+to8waRi+piomovMM-H7_7GdzyhYuEo@mail.gmail.com>
	<0F40C51E-38A3-451B-9D88-586CFD82EF8F@oracle.com>
Date: Fri, 11 Feb 2011 18:57:04 -0400
Message-ID: <AANLkTiksVebz5Pc+hH55hRUgvQ5PMFE1DG2X1JWbtSeD@mail.gmail.com>
Subject: Re: NFS only mount with -o udp option
From: Edgar Almonte <samudhio@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[root@circle zen]# pacman -Qs nfs-utils
local/nfs-utils 1.2.2-4 [0.69 MB]
    Support programs for Network File Systems
[root@circle zen]# uname -a
Linux circle 2.6.36-ARCH #1 SMP PREEMPT Mon Jan 24 18:34:55 UTC 2011
i686 Intel(R) Atom(TM) CPU D510 @ 1.66GHz GenuineIntel GNU/Linux


On Fri, Feb 11, 2011 at 1:40 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Which nfs-utils version and kernel release are you using?  What transport protocols are available from your NFS server?  It looks like only UDP.  I recall a bug fix in this area in the past year.
>
> On Feb 11, 2011, at 12:35 PM, Edgar Almonte wrote:
>
>> i get this without udp option:
>>
>> mount: no type was given - I'll assume nfs because of the colon
>> mount.nfs: timeout set for Fri Feb 11 13:27:33 2011
>> mount.nfs: trying text-based options
>> 'vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
>> mount.nfs: mount(2): No such file or directory
>> mount.nfs: trying text-based options
>> 'vers=4,addr=fe80::224:21ff:fe57:368d,clientaddr=::'
>> mount.nfs: mount(2): Input/output error
>> mount.nfs: mount system call failed
>>
>>
>> and with udp option:
>>
>> ount: no type was given - I'll assume nfs because of the colon
>> mount.nfs: timeout set for Fri Feb 11 13:28:29 2011
>> mount.nfs: trying text-based options
>> 'udp,vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
>> mount.nfs: mount(2): No such file or directory
>> mount.nfs: trying text-based options 'udp,addr=192.168.1.102'
>> mount.nfs: prog 100003, trying vers=3, prot=17
>> mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot UDP port 2049
>> mount.nfs: prog 100005, trying vers=3, prot=17
>> mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41044
>> heaven.local:/STORAGE on /nfs/STORAGE type nfs (rw,udp)
>>
>>
>> for other distro ( debian laptop ) without the udp option:
>>
>> mount: no type was given - I'll assume nfs because of the colon
>> mount.nfs: timeout set for Fri Feb 11 13:31:37 2011
>> mount.nfs: trying text-based options
>> 'vers=4,addr=192.168.1.102,clientaddr=192.168.1.107'
>> mount.nfs: mount(2): No such file or directory
>> mount.nfs: trying text-based options 'addr=192.168.1.102'
>> mount.nfs: prog 100003, trying vers=3, prot=6
>> mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot TCP port 2049
>> mount.nfs: prog 100005, trying vers=3, prot=17
>> mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41044
>> heaven.local:/STORAGE on /srv/nfs type nfs (rw)
>>
>>
>> and look like is some ipv6 issues
>>
>>
>> On Thu, Feb 10, 2011 at 11:50 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> On Feb 9, 2011, at 7:59 PM, Edgar Almonte wrote:
>>>
>>>> hello list
>>>>
>>>> like the subject say after some upgrade of my distro ( i have 2
>>>> machine with the same distro and only in one happne the problem ) i
>>>> can only mount nfs share using the option -o udp , without it i get
>>>> this error
>>>> mount.nfs: mount system call failed
>>>
>>> What does
>>>
>>>  sudo mount.nfs heaven.local:/STORAGE /nfs/STORAGE -v
>>>
>>> say?  It should tell you how the mount command is negotiating with the server.
>>>
>>>> i am using avahi-dns ( mdns ) for hostname resolve
>>>>
>>>> command used:
>>>> mount heaven.local:/STORAGE /nfs/STORAGE/
>>>> check dns is work right :
>>>>
>>>> ping heaven.local
>>>> PING heaven.local (192.168.1.102) 56(84) bytes of data.
>>>> 64 bytes from heaven.local (192.168.1.102): icmp_seq=1 ttl=64 time=0.153 ms
>>>> 64 bytes from heaven.local (192.168.1.102): icmp_seq=2 ttl=64 time=0.160 ms
>>>> ^C
>>>> --- heaven.local ping statistics ---
>>>> 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
>>>> rtt min/avg/max/mdev = 0.153/0.156/0.160/0.013 ms
>>>>
>>>>
>>>> anyidea what i need check for solve this issue ?
>>>>
>>>> thanks
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>>>
>>>
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
>
