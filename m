Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:49434 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbaD0LLy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 07:11:54 -0400
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20140427200431.426c98d1@notabene.brown>
References: <1398087935-14001-1-git-send-email-jlayton@redhat.com>
 <20140421140246.GB26358@brightrain.aerifal.cx> <535529FA.8070709@gmail.com>
 <20140421161004.GC26358@brightrain.aerifal.cx> <5355644C.7000801@gmail.com>
 <20140421184640.GD26358@brightrain.aerifal.cx> <535573E0.9080106@gmail.com>
 <20140421155520.3b33fbef@ipyr.poochiereds.net> <53558A73.3010602@samba.org>
 <5355F60C.8010004@gmail.com> <20140427145125.21e7e6c6@notabene.brown>
 <535CCAD2.4060304@gmail.com> <20140427200431.426c98d1@notabene.brown>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Sun, 27 Apr 2014 13:11:33 +0200
Message-ID: <CAKgNAkgv5NqDRUNu0XtSABqmctd7=rpMMEYhhDQNzPssZuU5bA@mail.gmail.com>
Subject: Re: flock() and NFS [Was: Re: [PATCH] locks: rename file-private
 locks to file-description locks]
To: NeilBrown <neilb@suse.de>
Cc: "Stefan (metze) Metzmacher" <metze@samba.org>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Suresh Jayaraman <sjayaraman@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 27, 2014 at 12:04 PM, NeilBrown <neilb@suse.de> wrote:
> On Sun, 27 Apr 2014 11:16:02 +0200 "Michael Kerrisk (man-pages)"
> <mtk.manpages@gmail.com> wrote:
>
>> [Trimming some folk from CC, and adding various NFS people]
>>
>> On 04/27/2014 06:51 AM, NeilBrown wrote:
>>
>> [...]
>>
>> > Note to Michael: The text
>> >    flock() does not lock files over NFS.
>> > in flock(2) is no longer accurate.  The reality is ... complex.
>> > See nfs(5), and search for "local_lock".
>>
>> Ahhh -- I see:
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5eebde23223aeb0ad2d9e3be6590ff8bbfab0fc2
>>
>> Thanks for the heads up.
>>
>> Just in general, it would be great if the flock(2) and fcntl(2) man pages
>> contained correct details for NFS, of course. So, for example, if there
>> are any current gotchas for NFS and fcntl() byte-range locking, I'd like
>> to add those to the fcntl(2) man page.
>
> The only peculiarities I can think of are:
>  - With NFS, locking or unlocking a region forces a flush of any cached data
>    for that file (or maybe for the region of the file).  I'm not sure if this
>    is worth mentioning.

I agree that it's probably not necessary to mention.

>  - With NFSv4 the client can lose a lock if it is out of contact with the
>    server for a period of time.  When this happens, any IO to the file by a
>    process which "thinks" it holds a lock will fail until that process closes
>    and re-opens the file.
>    This behaviour is since 3.12.  Prior to that the client might lose and
>    regain the lock without ever knowing thus potentially risking corruption
>    (but only if client and server lost contact for an extended period).

Do you have a pointer for that commit to 3.12?

>> Anyway, returning to your point about flock(), how would this text
>> look for the flock(2) manual page:
>>
>>     NOTES
>>        Since  kernel  2.0,  flock() is implemented as a system call in
>>        its own right rather than being emulated in the GNU  C  library
>>        as  a  call  to fcntl(2).  This yields classical BSD semantics:
>>        there is no interaction between the types  of  lock  placed  by
>>        flock()  and  fcntl(2),  and  flock() does not detect deadlock.
>>        (Note, however, that on some modern BSDs, flock() and  fcntl(2)
>>        locks do interact with one another.)
>>
>>        In Linux kernels up to 2.6.11, flock() does not lock files over
>>        NFS (i.e., the scope of locks was limited to the local system).
>>        Instead,  one could use fcntl(2) byte-range locking, which does
>>        work over NFS, given a sufficiently recent version of Linux and
>>        a  server  which  supports  locking.   Since  Linux 2.6.12, NFS
>>        clients support flock() locks by emulating them  as  byte-range
>>        locks on the entire file.  This means that fcntl(2) and flock()
>>        locks do interact with  one  another  over  NFS.   Since  Linux
>>        2.6.37,  the  kernel  supports a compatibility mode that allows
>>        flock() locks (and also  fcntl(2)  byte  region  locks)  to  be
>>        treated  as  local; see the discussion of the local_lock option
>>        in nfs(5).
>> ?
>
> That seems to cover it quite well - thanks.

Thanks for checking it.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
