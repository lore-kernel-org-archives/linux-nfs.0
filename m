From: Juergen Kreileder <jk@blackdown.de>
Subject: Bug#202756: [jk@blackdown.de: Re: Bug#202756: nfs-kernel-server: 1.0.5-1 works with libc6 from unstable but fails with libc6 2.3.2-1 from experimental]
Date: Sat, 20 Sep 2003 07:48:53 +0200
Message-ID: <87r82cj9h6.fsf@zaphod.blackdown.de>
References: <20030915021427.GA8188@perlsupport.com>
Reply-To: Juergen Kreileder <jk@blackdown.de>, 202756@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, 202756@bugs.debian.org
Return-path: <bounce-debian-glibc=debian-glibc=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.202756.B202756.106403697721941@bugs.debian.org>
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20030915021427.GA8188@perlsupport.com> (Chip Salzenberg's
 message of "Sun, 14 Sep 2003 22:14:27 -0400")
List-Post: <mailto:debian-glibc@lists.debian.org>
List-Help: <mailto:debian-glibc-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-glibc-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-glibc-request@lists.debian.org?subject=unsubscribe>
List-Archive: <http://lists.debian.org/debian-glibc/>
List-ID: <nfs.lists.sourceforge.net>

Chip Salzenberg <chip@pobox.com> writes:

> I'm not sure this information made it to the NFS list, so here it
> is.  Key points:
>
> * 1.0.6 does _not_ fix the crash.
>
> * preloading libpthread.so.0 is still an effective workaround
> (well, more of a diagnostic, really - we can't do it for production)
>
> Juergen's conclusion seems disturbingly true:
>> There must be something else in libpthread that is needed either by
>> mountd or glibc's RPC code.

Looks like a glibc problem, it's triggered by using lwres in nsswitch.conf.
See http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=211621


        Juergen

-- 
Juergen Kreileder, Blackdown Java-Linux Team
http://www.blackdown.org/java-linux/java2-status/
