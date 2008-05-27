From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Tue, 27 May 2008 17:37:43 +0200
Message-ID: <9e8c52a20805270837i73d51bdbwa66aead92ee5d3e3@mail.gmail.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	 <20080519144806.GB7622@fieldses.org>
	 <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
	 <RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
	 <9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
	 <20080526074054.141945a7@tleilax.poochiereds.net>
	 <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7@mail.gmail.com>
	 <RTPCLUEXC1-PRDqYW8B0000016d@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Jeff Layton" <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:12357 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756528AbYE0Php (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 11:37:45 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1160486nfc.21
        for <linux-nfs@vger.kernel.org>; Tue, 27 May 2008 08:37:43 -0700 (PDT)
In-Reply-To: <RTPCLUEXC1-PRDqYW8B0000016d-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 27, 2008 at 3:32 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
> At 08:15 AM 5/27/2008, Alexander Borghgraef wrote:
>>It varies. I've had occurrences where it lasted for 15mins, but recent
>>ones have been too short to register.
>
> When you say "lasted", do you mean the file with the problem starts to
> work (i.e. shows attributes), or that it basically vanishes?

The file shows its attributes again, no data is lost.

> I am thinking
> that perhaps the client thinks the file exists, but the server disagrees.
> If you have multiple mail servers and there's an application synchronization
> issue, this could be the problem.

I do have two pop accounts running in kmail. Never had any problems
with that before.

> Also, are the clocks synchronized between your clients and the server?
> Clock skew can make this kind of problem worse.

I think both use ntp protocol, but I'm not sure.

>>> If so, it might be interesting to run:
>>>
>>>    strace stat cur

Just had another event, so I ran strace stat on the offending
directory, and then later again when everything was back to normal.
The output is pretty long, so I'll just include the part where it
starts calling on 'cur' where it went wrong. If you want the full
logs, I'll post them later. Here it is:

lstat64("cur", 0xbfb81cb4)              = -1 ENOENT (No such file or directory)
open("/usr/share/locale/locale.alias", O_RDONLY) = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=2528, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0xb7f8b000
read(3, "# Locale name alias data base.\n#"..., 4096) = 2528
read(3, "", 4096)                       = 0
close(3)                                = 0
munmap(0xb7f8b000, 4096)                = 0
open("/usr/share/locale/en_US.UTF-8/LC_MESSAGES/coreutils.mo",
O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale/en_US.utf8/LC_MESSAGES/coreutils.mo",
O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale/en_US/LC_MESSAGES/coreutils.mo", O_RDONLY) =
-1 ENOENT (No such file or directory)
open("/usr/share/locale/en.UTF-8/LC_MESSAGES/coreutils.mo", O_RDONLY)
= -1 ENOENT (No such file or directory)
open("/usr/share/locale/en.utf8/LC_MESSAGES/coreutils.mo", O_RDONLY) =
-1 ENOENT (No such file or directory)
open("/usr/share/locale/en/LC_MESSAGES/coreutils.mo", O_RDONLY) = -1
ENOENT (No such file or directory)
write(2, "stat: ", 6stat: )                   = 6
write(2, "cannot stat `cur\'", 17cannot stat `cur')      = 17
open("/usr/share/locale/en_US.UTF-8/LC_MESSAGES/libc.mo", O_RDONLY) =
-1 ENOENT (No such file or directory)
open("/usr/share/locale/en_US.utf8/LC_MESSAGES/libc.mo", O_RDONLY) =
-1 ENOENT (No such file or directory)
open("/usr/share/locale/en_US/LC_MESSAGES/libc.mo", O_RDONLY) = -1
ENOENT (No such file or directory)
open("/usr/share/locale/en.UTF-8/LC_MESSAGES/libc.mo", O_RDONLY) = -1
ENOENT (No such file or directory)
open("/usr/share/locale/en.utf8/LC_MESSAGES/libc.mo", O_RDONLY) = -1
ENOENT (No such file or directory)
open("/usr/share/locale/en/LC_MESSAGES/libc.mo", O_RDONLY) = -1 ENOENT
(No such file or directory)
write(2, ": No such file or directory", 27: No such file or directory) = 27
write(2, "\n", 1
)                       = 1
close(1)                                = 0
close(2)                                = 0
exit_group(1)                           = ?

The missing /usr/share/... directories are not there in both cases,
probably the consequence of some decrepit path files, so I don't think
they're very relevant. These are the final lines of the strace when
everything went back to normal again:


write(1, "  File: `cur\'\n  Size: 12288     "..., 328  File: `cur'
  Size: 12288     	Blocks: 24         IO Block: 8192   directory
Device: 18h/24d	Inode: 12451867    Links: 2
Access: (0700/drwx------)  Uid: (  522/aborghgr)   Gid: (   21/ slocate)
Access: 2008-05-27 17:04:33.950166824 +0200
Modify: 2008-05-27 14:37:26.216635651 +0200
Change: 2008-05-27 14:37:26.216635651 +0200
) = 328
close(1)                                = 0
munmap(0xb7f05000, 8192)                = 0
close(2)                                = 0
exit_group(0)


> And if it shows a hard error, please also turn on a few NFS client
> debugging flags and capture the log:
>
>        rpcdebug -m nfs -s dircache lookupcache
>        stat cur
>        dmesg >/tmp/send-this-log
>        rpcdebug -m nfs -c dircache lookupcache

Hmm, don't have access for that. I'm running into the limits of what I
can do here, so if it comes down to debugging nfs, I'll have to hand
over things to our sysadmin.

-- 
Alex Borghgraef
