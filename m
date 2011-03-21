Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.conversis.de ([213.203.219.181]:54617 "EHLO
	mail4.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551Ab1CUM6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2011 08:58:30 -0400
Message-ID: <4D874419.5030303@conversis.de>
Date: Mon, 21 Mar 2011 13:27:05 +0100
From: Dennis Jacobfeuerborn <dennisml@conversis.de>
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: bind mounts, crossmnt and multi client nfsv3
References: <4D86B6F2.1070004@conversis.de> <20110321140923.5a618d89@notabene.brown>
In-Reply-To: <20110321140923.5a618d89@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/21/2011 04:09 AM, NeilBrown wrote:
> On Mon, 21 Mar 2011 03:24:50 +0100 Dennis Jacobfeuerborn
> <d.jacobfeuerborn@conversis.de>  wrote:
>
>> Hi,
>> I have a storage system that is exporting many directories to multiple
>> clients resulting in a lot of mountpoints (156) on each client. What I'm
>> trying to do is to create a single directory on the server and then use
>> mount --bind to mount all the different directories (which are stored on
>> different LVM volumes) into this single export directory and finally export
>> this directory to the clients.
>> Now the exports man-page mentions the crossmnt option but it also mentions
>> that it cannot be used if I want to export the directory to multiple
>> clients. Is there another way to accomplish something like this?
>>
>
> Just export the top directory with 'crossmnt' - it should work fine.
>
> The 'multiple clients' thing only affects 'nohide' and I think it only
> affected it back in 2.4 days.
> Lots changed with 2.6, but maybe not enough of the man page changed :-(
>
> So try with 'crossmnt' and if it doesn't work, then come back with details.

I've tried this now but it doesn't seem to work. This is the setup so far:

===========

On the server I've created the bind mounts like this:

/mnt/vg0/vol01/country/de/a on /exports/country/de/a type none (rw,bind)
/mnt/vg0/vol03/country/de/b on /exports/country/de/b type none (rw,bind)
...

Then I put the following line in /etc/exports:
/exports 
192.168.0.0/255.255.255.0(rw,anonuid=96,anongid=96,secure,no_root_squash,wdelay,sync,crossmnt,no_subtree_check)

additionally these exports exist for each volume:
/mnt/vg0/vol01/country 
213.131.252.0/255.255.255.0(rw,anonuid=96,anongid=96,secure,no_root_squash,wdelay,sync)

===========

On the client I've mounted this export like this:
mount -o rw,noatime,tcp,rsize=8192,hard,intr,nfsvers=3,addr=192.168.0.8 
192.168.0.8:/exports/country/de /data/country/de

This succeeds and I can see the letters a-z in /data/country/de however 
these directories are all empty so crossing the filesystem border doesn't 
seem to work.

===========

The server is an openfiler appliance:

[root@exonas900 ~]# conary q|grep nfs
libnfsidmap=0.20-1.1-1
nfs-client=1.0.10-4.6-1
nfs-server=1.0.10-4.6-1
nfs-utils=1.0.10-4.6-1
[root@exonas900 ~]# uname -a
Linux exonas900 2.6.26.8-1.0.11.smp.gcc3.4.x86.i686 #1 SMP Sat Jan 10 
22:09:09 GMT 2009 i686 i686 i386 GNU/Linux

===========

The client I'm testing with is a Centos 5 system:

[root@wmembf10 ~]# rpm -qa|grep nfs
nfs-utils-lib-1.0.8-7.6.el5
nfs-utils-1.0.9-47.el5_5
[root@wmembf10 ~]# uname -a
Linux wmembf10.tmm.cvsn.de 2.6.18-194.11.4.el5xen #1 SMP Tue Sep 21 
05:40:24 EDT 2010 x86_64 x86_64 x86_64 GNU/Linux

Regards,
   Dennis
