Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57752 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754847Ab2IHPPm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Sep 2012 11:15:42 -0400
Received: by eekc1 with SMTP id c1so284481eek.19
        for <linux-nfs@vger.kernel.org>; Sat, 08 Sep 2012 08:15:41 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 8 Sep 2012 10:15:41 -0500
Message-ID: <CAEeMGHu1jvDYEg0JHNY6OEtG_XUR-jpXMM88hxvve=fdA-VU=A@mail.gmail.com>
Subject: how is the wsize mount option able to turn client data read caching
 on or off with nfsv3 connections?
From: Sabuj Pattanayek <sabujp@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I'm hoping someone could shed some light on this behavior I'm seeing
with respect to the client cache during reads with nfsv3 that seem to
only be dependent (based on my observations) on the wsize parameter
during mount. On one of our NAS systems (call this NAS X) the
recommended wsize & rsize is 32k and iirc when mounting between two
centos6 systems or probably any linux systems in general the rwsize
are both 4k. When mounted to this NAS solution or another linux
(centos6) system I always see a read cache effect as long as the file
I'm writing out and then reading back in is less than total available
memory on the box :

% time dd if=/dev/zero of=testFile bs=1M count=512 && time dd
if=testFile of=/dev/null bs=1M
512+0 records in
512+0 records out
536870912 bytes (537 MB) copied, 5.54986 s, 96.7 MB/s
0.000u 0.392s 0:05.57 7.0%	0+0k 0+1048576io 0pf+0w
512+0 records in
512+0 records out
536870912 bytes (537 MB) copied, 0.0771571 s, 7.0 GB/s
0.000u 0.076s 0:00.07 100.0%	0+0k 0+0io 0pf+0w

I can use a bs=4k and I see the same caching behavior as well. This
caching effect is good and reduces the number of read I/O's on things
like compiles and when doing any task when a write is followed at some
point by a read on the same file(s).

On another NAS solution (call this NAS Y) the automatically negotiated
rsize is 128k and wsize is 512k. I can make the the rsize whatever I
want but as long as wsize is not >=512k I never see the read caching
effect, and even when wsize is >=512k, unlike NAS X or when mounted to
a linux system, I get the read caching effect perhaps 80-90% of the
time vs 100% of the time on the other systems. One modification that I
was able to make internally on NAS Y to get the read caching effect
100% of the time *regardless of the wsize* was to set the behavior of
unstable writes to datasync, i.e. even if the client is requesting an
async mount internally the server does a datasync (on each block or
file?). This however will greatly reduce random write and small file
write performance so is not a good solution.

Testing some more, I saw that I was able to break the read caching
behavior on NAS X by reducing the wsize to 8k.

Any idea on how to get NAS Y to give me the desired read caching
effect 100% of the time without using a ridiculous wsize or setting
unstable writes internally on the NAS to datasync? There was also an
option to cause NAS Y to send back a datasync reply on an unstable
write, i.e. fake the reply to the NFS client I guess, but this had no
effect. Or any idea in general about how wsize is changing the read
caching behavior on linux?

I'm using these mount options:

mount -t nfs -o
rw,tcp,vers=3,intr,bg,hard,cto,rdirplus,async,wsize=whatever
nas:/share /local/dir

I'm aware that cto,rdirplus,async are default. Changing to nocto has
no effect on the read caching behavior.

Thanks,
Sabuj Pattanayek
