From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Sun, 22 Jun 2008 11:35:33 +0300
Message-ID: <485E0ED5.7030501@panasas.com>
References: <OF9EA6D38A.FDD1F48D-ON6525746E.002D25B8-6525746E.003360EB@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:42179 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbYFVIfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jun 2008 04:35:39 -0400
Received: by wx-out-0506.google.com with SMTP id h29so577970wxd.4
        for <linux-nfs@vger.kernel.org>; Sun, 22 Jun 2008 01:35:38 -0700 (PDT)
In-Reply-To: <OF9EA6D38A.FDD1F48D-ON6525746E.002D25B8-6525746E.003360EB@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 20, 2008, 12:21 +0300, Krishna Kumar2 <krkumar2@in.ibm.com> wrote:
> Benny Halevy <bhalevy@panasas.com> wrote on 06/19/2008 06:22:42 PM:
> 
>>> Well, you aren't exactly comparing apples to apples.  The NFS
>>> client does close-to-open semantics, meaning that it writes
>>> all modified data to the server on close.  The dd commands run
>>> on the local file system do not.  You might trying using
>>> something which does an fsync before closing so that you are
>>> making a closer comparison.
>> try dd conv=fsync ...
> 
> I ran a single 'dd' with this option on /local and later on /nfs (same
> filesystem nfs mounted on the same system). The script is umounting and
> mounting local and nfs partitions between each 'dd'. Following are the
> file sizes for 20 and 60 second runs respectively:

According to dd's man page, the f{,date}sync options tell it to
"physically write output file data before finishing"
If you kill it before that you end up with dirty data in the cache.
What exactly are you trying to measure, what is the expected application
workload?

>       -rw-r--r-- 1 root root 1558056960 Jun 20 14:41 local.1
>       -rw-r--r-- 1 root root  671834112 Jun 20 14:41 nfs.1     (56% drop)
>                         &
>       -rw-r--r-- 1 root root 3845812224 Jun 20 14:42 local.1
>       -rw-r--r-- 1 root root 2420342784 Jun 20 14:43 nfs.1     (37% drop)
> 
> Since I am new to NFS, I am not sure if this much degradation is expected,
> or whether I need to tune something. Is there some code I can look at or
> hack into to find possible locations for the performance fall? At this time
> I cannot even tell whether the *possible* bug is in server or client code.

I'm not sure if there's a any bug per-se at all although there seems to be
some room for improvement.

As another data point, I'm seeing about 20% worse write throughput on my
system with a single dd writing local file system vs. writing to the same fs
over a loopback mounted nfs with a 2.6.26-rc6 based kernel (nfs 3 and 4 gave
similar results).
Disk:
ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata3.00: ATA-7: HDT722516DLA380, V43OA96A, max UDMA/133
ata3.00: 321672960 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata3.00: configured for UDMA/133

ext3 mount options: noatime
nfs mount options: rsize=65536,wsize=65536
dd options: bs=64k count=10k conv=fsync

(write results average of 3 runs)
write local disk:     47.6 MB/s
write loopback nfsv3: 30.2 MB/s
write remote nfsv3:   29.0 MB/s
write loopback nfsv4: 37.5 MB/s
write remote nfsv4:   29.1 MB/s

read local disk:      50.8 MB/s
read loopback nfsv3:  27.2 MB/s
read remote nfsv3:    21.8 MB/s
read loopback nfsv4:  25.4 MB/s
read remote nfsv4:    21.4 MB/s

Benny

> 
> Thanks,
> 
> - KK
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

