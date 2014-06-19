Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:57582 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755658AbaFSN2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2014 09:28:48 -0400
Message-ID: <53A2E584.50106@alex.org.uk>
Date: Thu, 19 Jun 2014 14:28:36 +0100
From: Alex Bligh <alex@alex.org.uk>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: Peculiarity in handling NFSv4 mount paths with fsid=0
References: <EB04E1C061D36F087D431E74@nimrod.local> <20140618162735.34b3ae50@notabene.brown>
In-Reply-To: <20140618162735.34b3ae50@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Neil,

On 18/06/2014 07:27, NeilBrown wrote:
> On Sat, 14 Jun 2014 10:37:14 +0100 Alex Bligh <alex@alex.org.uk>
> wrote:
> 
>> I've discovered I think a peculiarity with handling mount paths
>> with fsid=0.
> 
> It looks to me like this has nothing to do with "fsid=0" and
> everything to do with using the expected number of '/' characters.

I don't *think* I saw the same issue without fsid=0, but I might be
wrong.

>> This is on Ubuntu Precise (old) but I've used 3.13 too with the
>> same problem.
>> 
>> I have an exports line like this: /storage/local 
>> *(rw,sync,wdelay,nohide,crossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534)
>>
>>
>>
>> 
And mounted a directory like this (which succeeded)
>> 
>> # mount -t nfs4 10.157.208.1:nfs-01 /mnt
>> 
>> And unmount did this:
>> 
>> # umount 10.157.208.1:nfs-01 /mnt was not found in /proc/mounts 
>> /mnt was not found in /proc/mounts
>> 
>> Examination showed /proc/mounts contained the line:
>> 
>> 10.157.208.1:/nfs-01 /mnt nfs4 
>> rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.157.208.1,local_lock=none,addr=10.157.208.1
>>  0 0
>> 
>> Whereas the outptut of 'mount' contained the line:
>> 
>> 10.157.208.1:nfs-01 on /mnt type nfs4 
>> (rw,addr=10.157.208.1,clientaddr=10.157.208.1)
>> 
>> There is a difference here between "/nfs-01" and "nfs-01".
>> 
>> This might merely be an annoying bug, where it not for the fact
>> that as far as I can tell the mount is now cannot be unmounted
>> with userspace tools. No amount of --fake and -n appears to help.
>> System reset required.
> 
> Doesn't umount /mnt work?

No, umount /mnt gives the same error.

> 
> 
>> 
>> Of course had I typed:
>> 
>> # mount -t nfs4 10.157.208.1:/nfs-01 /mnt
>> 
>> all would have been well.
>> 
>> I suspect something should be canonicalising the path
>> consistently.
>> 
> 
> I agree there.
> 
> NeilBrown
> 


- -- 
Alex Bligh
-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.22 (Darwin)
Comment: GPGTools - https://gpgtools.org
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTouWDAAoJEBPm5K7i9iORxgMQAJmkJj1vz2ghKOYxcFqpFh/d
ZM0jncL40CB+50yLeGOBPlJshx2tvX0hKdMUQa0JWy0+IBi8QhuEtmU7lXB/Ifri
CEoBVIV2dNRQgGcYUpRjszsSc+vEvWIfOZ/oLpq7JFI10LFGzmUZXS4cNdtNqnDv
L4Yejlvj0O33zwolHFaVnaAg21Ybzg20TtVnWsQPgNcnQljPVD9lr1kmXDAqA1kx
SfQ+2HccjaRFawf9Y5m+o29D/I0D0k23O4Zxjk/Bvv4xiQ2jXfCokWXeVLYbuzdm
7sEVEkncNnOaBAxWH54+F3YYzS6w9lXMP3MrE1NCPFGMvGvwBqfKC3gEE/ZTNMQ6
jvzZuQVVqSic9E8LHjlQ7x/SAhUXJkUojokRKnoje3m2MWjqY0tOJfZnQG3E15Zo
jHVT16gHkNgsWNmny/cUtQTcg2l1GCDwAzY7HtdtVAHQrMd0jgx8wqFU5/7D9iuf
IxakWABbJ3pa6p1g8NkaDELDcXZMMXWzucst763ke8BwDPnTzJFxgQnw0LcxaRPU
FutJRpHh0y8JLda//aYB00qEiBRxk6CheqrQfiOAdHIBqghT451SreH2BY4FqT2v
YXEwgrCj9WyCqFIJrkZEr5WvXYkAryi32E2daeU7qdMQbj0DCHsjFjw8OMRGCQjQ
TqinXeStk19lDrNcnXEI
=5HjR
-----END PGP SIGNATURE-----
