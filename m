Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f54.google.com ([74.125.83.54]:48270 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbaD2JHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 05:07:22 -0400
Message-ID: <535F6BC4.2090601@gmail.com>
Date: Tue, 29 Apr 2014 11:07:16 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: mtk.manpages@gmail.com, "Stefan (metze) Metzmacher" <metze@samba.org>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Suresh Jayaraman <sjayaraman@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: flock() and NFS [Was: Re: [PATCH] locks: rename file-private
 locks to file-description locks]
References: <1398087935-14001-1-git-send-email-jlayton@redhat.com>	<20140421140246.GB26358@brightrain.aerifal.cx>	<535529FA.8070709@gmail.com>	<20140421161004.GC26358@brightrain.aerifal.cx>	<5355644C.7000801@gmail.com>	<20140421184640.GD26358@brightrain.aerifal.cx>	<535573E0.9080106@gmail.com>	<20140421155520.3b33fbef@ipyr.poochiereds.net>	<53558A73.3010602@samba.org>	<5355F60C.8010004@gmail.com>	<20140427145125.21e7e6c6@notabene.brown>	<535CCAD2.4060304@gmail.com>	<20140427200431.426c98d1@notabene.brown>	<CAKgNAkgv5NqDRUNu0XtSABqmctd7=rpMMEYhhDQNzPssZuU5bA@mail.gmail.com> <20140428072845.67f48d8e@notabene.brown>
In-Reply-To: <20140428072845.67f48d8e@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/27/2014 11:28 PM, NeilBrown wrote:
> On Sun, 27 Apr 2014 13:11:33 +0200 "Michael Kerrisk (man-pages)"
> <mtk.manpages@gmail.com> wrote:
> 
>> On Sun, Apr 27, 2014 at 12:04 PM, NeilBrown <neilb@suse.de> wrote:
>>> On Sun, 27 Apr 2014 11:16:02 +0200 "Michael Kerrisk (man-pages)"
>>> <mtk.manpages@gmail.com> wrote:
>>>
>>>> [Trimming some folk from CC, and adding various NFS people]
>>>>
>>>> On 04/27/2014 06:51 AM, NeilBrown wrote:
>>>>
>>>> [...]
>>>>
>>>>> Note to Michael: The text
>>>>>    flock() does not lock files over NFS.
>>>>> in flock(2) is no longer accurate.  The reality is ... complex.
>>>>> See nfs(5), and search for "local_lock".
>>>>
>>>> Ahhh -- I see:
>>>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5eebde23223aeb0ad2d9e3be6590ff8bbfab0fc2
>>>>
>>>> Thanks for the heads up.
>>>>
>>>> Just in general, it would be great if the flock(2) and fcntl(2) man pages
>>>> contained correct details for NFS, of course. So, for example, if there
>>>> are any current gotchas for NFS and fcntl() byte-range locking, I'd like
>>>> to add those to the fcntl(2) man page.
>>>
>>> The only peculiarities I can think of are:
>>>  - With NFS, locking or unlocking a region forces a flush of any cached data
>>>    for that file (or maybe for the region of the file).  I'm not sure if this
>>>    is worth mentioning.
>>
>> I agree that it's probably not necessary to mention.
>>
>>>  - With NFSv4 the client can lose a lock if it is out of contact with the
>>>    server for a period of time.  When this happens, any IO to the file by a
>>>    process which "thinks" it holds a lock will fail until that process closes
>>>    and re-opens the file.
>>>    This behaviour is since 3.12.  Prior to that the client might lose and
>>>    regain the lock without ever knowing thus potentially risking corruption
>>>    (but only if client and server lost contact for an extended period).
>>
>> Do you have a pointer for that commit to 3.12?
>>
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ef1820f9be27b6ad158f433ab38002ab8131db4d
> 
> did most of the work while  the subsequent commit
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f6de7a39c181dfb8a2c534661a53c73afb3081cd
> 
> changed some details, added some documentation, and inverted the default
> behaviour.

Thanks for that detail. What do you think of the following text for the 
fcntl(2) man page:

       Before  Linux 3.12, if an NFS client is out of contact with the
       server for a period of time, it might lose and  regain  a  lock
       without  ever  being  aware  of the fact.  This scenario poten‐
       tially risks  data  corruption,  since  another  process  might
       acquire  a lock in the intervening period and perform file I/O.
       Since Linux 3.12, if the client loses contact with the  server,
       any I/O to the file by a process which "thinks" it holds a lock
       will fail until that process closes and reopens  the  file.   A
       kernel  parameter,  nfs.recover_lost_locks,  can be set to 1 to
       obtain the pre-3.12 behavior, whereby the client  will  attempt
       to  recover  lost  locks when contact is reestablished with the
       server.  Because of the attendant risk of data corruption, this
       parameter defaults to 0 (disabled).

?

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
