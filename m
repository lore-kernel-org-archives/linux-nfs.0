Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbZICSft (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 14:35:49 -0400
Message-ID: <4AA00CFF.6010304@redhat.com>
Date: Thu, 03 Sep 2009 14:37:51 -0400
From: Ric Wheeler <rwheeler@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Peter Staubach <staubach@redhat.com>, Jason Legate <linux-nfs@proxime.net>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS for millions of files
References: <20090902180841.GF946@proxime.net> <4A9EBB6B.4040009@redhat.com> <20090903181535.GA10670@fieldses.org>
In-Reply-To: <20090903181535.GA10670@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/03/2009 02:15 PM, J. Bruce Fields wrote:
> On Wed, Sep 02, 2009 at 02:37:31PM -0400, Peter Staubach wrote:
>    
>> Please keep in mind that the NFS stable storage requirements are
>> probably causing a significant slowdown in activities such as this.
>>      
> My first thought too, but:
>
>    
>> Jason Legate wrote:
>>      
>>> When I run our creation benchmark locally  I can get around 3000
>>> files/ second in the configuration we're using now, but only around
>>> 300/second over NFS.  It's mounted as this:
>>>        
> ...
>    
>>> When I mount the same FS over localhost instead of across the lan,
>>> it performs about full speed (the 3000/sec).
>>>        
> The localhost NFS mount would be incurring the same sync latency, so all
> his latency must be due to network.  (And with those numbers I guess
> he's either got lots of disk spindles, or an ssd, or (uh-oh) has the
> async option set?)
>
> --b.
>    

For small files without doing an fsync per file, getting 3000 files/sec 
is not that much. Ext3 can do it with a local s-ata disk. I suspect that 
Jason would run much slower if he ran with local fsync()'s enabled 
(similar to what NFS servers have to do).

Some quick testing on a local F12 (rawhide) box:

No fsync: 3729 files/sec

[root@ricdesktop rwheeler]# fs_mark -s 20480 -n 10000 -S 0 -d /test/test_dir

#  fs_mark  -s  20480  -n  10000  -S  0  -d  /test/test_dir
#    Version 3.3, 1 thread(s) starting at Thu Sep  3 14:26:26 2009
#    Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
#    Directories:  no subdirectories used
#    File names: 40 bytes long, (16 initial bytes of time stamp with 24 
random bytes at end of name)
#    Files info: size 20480 bytes, written with an IO size of 16384 
bytes per write
#    App overhead is time in microseconds spent in the test not doing 
file writing related system calls.

FSUse%        Count         Size    Files/sec     App Overhead
      5        10000        20480       3729.0           315859

Fsync & working barriers: 24.8 files/sec

[root@ricdesktop rwheeler]# fs_mark -s 20480 -n 10000 -S 1 -d /test/test_dir

#  fs_mark  -s  20480  -n  10000  -S  1  -d  /test/test_dir
#    Version 3.3, 1 thread(s) starting at Thu Sep  3 14:27:00 2009
#    Sync method: INBAND FSYNC: fsync() per file in write loop.
#    Directories:  no subdirectories used
#    File names: 40 bytes long, (16 initial bytes of time stamp with 24 
random bytes at end of name)
#    Files info: size 20480 bytes, written with an IO size of 16384 
bytes per write
#    App overhead is time in microseconds spent in the test not doing 
file writing related system calls.

FSUse%        Count         Size    Files/sec     App Overhead
      5        10000        20480         24.8           350322

Fsync/no write barriers: 377.1 files/sec

[root@ricdesktop rwheeler]# umount /test/
[root@ricdesktop rwheeler]# mount -o barrier=0 /dev/sdb /test/
[root@ricdesktop rwheeler]# fs_mark -s 20480 -n 10000 -S 1 -d /test/test_dir

#  fs_mark  -s  20480  -n  10000  -S  1  -d  /test/test_dir
#    Version 3.3, 1 thread(s) starting at Thu Sep  3 14:36:27 2009
#    Sync method: INBAND FSYNC: fsync() per file in write loop.
#    Directories:  no subdirectories used
#    File names: 40 bytes long, (16 initial bytes of time stamp with 24 
random bytes at end of name)
#    Files info: size 20480 bytes, written with an IO size of 16384 
bytes per write
#    App overhead is time in microseconds spent in the test not doing 
file writing related system calls.

FSUse%        Count         Size    Files/sec     App Overhead
      5        10000        20480        377.1           328472


Ric





