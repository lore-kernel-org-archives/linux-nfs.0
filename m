From: Chip Salzenberg <chip@pobox.com>
Subject: Bug#202756: [jk@blackdown.de: Re: Bug#202756: nfs-kernel-server: 1.0.5-1 works with libc6 from unstable but fails with libc6 2.3.2-1 from experimental]
Date: Sun, 14 Sep 2003 22:14:27 -0400
Sender: Chip Salzenberg <chip@tytlal.perlsupport.com>
Message-ID: <20030915021427.GA8188@perlsupport.com>
Reply-To: Chip Salzenberg <chip@pobox.com>, 202756@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juergen Kreileder <jk@blackdown.de>, 202756@bugs.debian.org
Return-path: <bounce-debian-glibc=debian-glibc=m.gmane.org@lists.debian.org>
Sender: Chip Salzenberg <chip@tytlal.perlsupport.com>
Resent-Message-ID: <handler.202756.B202756.106359209625355@bugs.debian.org>
To: nfs@lists.sourceforge.net
List-Post: <mailto:debian-glibc@lists.debian.org>
List-Help: <mailto:debian-glibc-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-glibc-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-glibc-request@lists.debian.org?subject=unsubscribe>
List-Archive: <http://lists.debian.org/debian-glibc/>
List-ID: <nfs.lists.sourceforge.net>

I'm not sure this information made it to the NFS list, so here it is.
Key points:

 * 1.0.6 does _not_ fix the crash.

 * preloading libpthread.so.0 is still an effective workaround
   (well, more of a diagnostic, really - we can't do it for production)

Juergen's conclusion seems disturbingly true:
> There must be something else in libpthread that is needed either by
> mountd or glibc's RPC code.


----- Forwarded message from Juergen Kreileder <jk@blackdown.de> -----

Subject: Re: Bug#202756: nfs-kernel-server: 1.0.5-1 works with libc6 from
 unstable but fails with libc6 2.3.2-1 from experimental
From: Juergen Kreileder <jk@blackdown.de>
To: Philip Blundell <philb@gnu.org>
Cc: 202756@bugs.debian.org, Chip Salzenberg <chip@debian.org>
Date: Wed, 10 Sep 2003 08:10:22 +0200

Philip Blundell <philb@gnu.org> writes:

> On Mon, 2003-09-08 at 01:57, Juergen Kreileder wrote:
>> With LD_PRELOAD=libpthread.so.0, mountd works fine.  I'm not sure
>> whether this is a glibc or an nfs-kernel-server bug: AFAIK mountd
>> doesn't use threads and should be OK with the functions from libc,
>> but it looks like it needs some of the overriden functions from
>> libpthread.
>>
>> If mountd doesn't use threads and if RPC doesn't require linking
>> with libpthread, then this is a glibc bug.
>
> Aha, okay.  Yes, I think this is a known bug, and we have a fix for
> it. I'll check the patch in later today and make a -6 release.
>
> Thanks for investigating!

-6 does NOT fix the problem!

Preloading libpthread.so.0 still works around the problem.

After reading Jakub's explanation for the patch...

,----[ http://sources.redhat.com/ml/libc-hacker/2003-09/msg00002.html ]
| B0rken software, which doesn't link shared libraries which use
| pthread_cond_timedwait against -lpthread is bitten by this.  With the
| exception of pthread_cond_timedwait, all pthread_cond_* routines have
| stubs in libc.so, so they are given @@GLIBC_2.3.2 version during
| linking. pthread_cond_timedwait doesn't have the stub, so unless
| -lpthread is specified (certainly the right thing to do), it remains
| unversioned. Mixing pthread_cond_*@GLIBC_2.3.2 and
| pthread_cond_timedwait@GLIBC_2.0 on one pthread_cond_t is deadly.
`----

...I don't think this patch applies to problem: mountd doesn't use
Pthreads at all and should work fine with linking libpthread or this
patch.

There must be something else in libpthread that is needed either by
mountd or glibc's RPC code.


        Juergen

-- 
Juergen Kreileder, Blackdown Java-Linux Team
http://www.blackdown.org/java-linux/java2-status/

----- End forwarded message -----

-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-- 
To UNSUBSCRIBE, email to debian-glibc-request@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian.org
