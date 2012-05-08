Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:44440 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991Ab2EHNoC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 May 2012 09:44:02 -0400
Message-ID: <4FA92319.6000007@pocock.com.au>
Date: Tue, 08 May 2012 13:43:53 +0000
From: Daniel Pocock <daniel@pocock.com.au>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
References: <4FA5E950.5080304@pocock.com.au> <1336328594.2593.14.camel@lade.trondhjem.org> <4FA6EBD4.7040308@pocock.com.au> <1336340993.2600.11.camel@lade.trondhjem.org> <4FA6F75E.6090300@pocock.com.au> <1336344160.2600.30.camel@lade.trondhjem.org> <4FA793AB.70107@pocock.com.au> <4FA7D54E.9080309@pocock.com.au> <20120507171759.GA10137@fieldses.org> <4FA90C63.7000505@pocock.com.au> <20120508124559.GA15448@fieldses.org>
In-Reply-To: <20120508124559.GA15448@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/05/12 12:45, J. Bruce Fields wrote:
> On Tue, May 08, 2012 at 12:06:59PM +0000, Daniel Pocock wrote:
>>
>>
>> On 07/05/12 17:18, J. Bruce Fields wrote:
>>> How many file creates per second?
>>>
>>
>> I ran:
>> nfsstat -s -o all -l -Z5
>> and during the test (unpacking the tarball), I see numbers like these
>> every 5 seconds for about 2 minutes:
>>
>> nfs v3 server        total:      319
>> ------------- ------------- --------
>> nfs v3 server      getattr:        1
>> nfs v3 server      setattr:      126
>> nfs v3 server       access:        6
>> nfs v3 server        write:       61
>> nfs v3 server       create:       61
>> nfs v3 server        mkdir:        3
>> nfs v3 server       commit:       61
> 
> OK, so it's probably creating about 60 new files, each requiring a
> create, write, commit, and two setattrs?
> 
> Each of those operations is synchronous, so probably has to wait for at
> least one disk seek.  About 300 such operations every 5 seconds is about
> 60 per second, or about 16ms each.  That doesn't sound so far off.
> 
> (I wonder why it needs two setattrs?)

I checked that with wireshark:
- first SETATTR sets mode=0644 and atime=mtime=`set to server time'
- second SETATTR sets atime and mtime using client values (atime=now,
mtime= some time in the past)

Is this likely to be an application issue (e.g. in tar), or should the
NFS client be able to merge those two requests somehow?

If I add `m' to my tar command (tar xzmf) the nfsstat results change:

nfs v3 server        total:      300
------------- ------------- --------
nfs v3 server      setattr:       82
nfs v3 server       lookup:       17
nfs v3 server       access:        5
nfs v3 server        write:       90
nfs v3 server       create:       83
nfs v3 server        mkdir:        3
nfs v3 server       remove:       15
nfs v3 server       commit:        5

and iostat reports that w/s is about the same (290/sec) but throughput
is now in the region 1.1 - 1.5MBytes/sec


Without using `m', here are the full stats from the Z800 acting as NFSv3
server:

nfs v3 server        total:      299
------------- ------------- --------
nfs v3 server      setattr:      132
nfs v3 server       access:        6
nfs v3 server        write:       88
nfs v3 server       create:       62
nfs v3 server        mkdir:        6
nfs v3 server       commit:        5

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s
avgrq-sz avgqu-sz   await  svctm  %util

dm-10             0.00     0.00    0.00  294.00     0.00     1.15
8.00     1.04    3.55   3.26  95.92

The other thing that stands out is this:
avgrq-sz = 8  (units = 512 byte sectors)

If the server filesystem is btrfs, the wMB/s figure is the same, but I
notice avgrq-sz = 16, so it seems to be combining more requests into
bigger writes


Here is the entry from /proc/mounts:
/dev/mapper/vg01-test1 /mnt/test1 ext4
rw,relatime,barrier=1,data=ordered 0 0




