From: Juergen Kreileder <jk@blackdown.de>
Subject: Bug#202756: [jk@blackdown.de: Re: Bug#202756: nfs-kernel-server: 1.0.5-1 works with libc6 from unstable but fails with libc6 2.3.2-1 from experimental]
Date: Sat, 20 Sep 2003 20:01:27 +0200
Message-ID: <87brtf9w5k.fsf@zaphod.blackdown.de>
References: <20030915021427.GA8188@perlsupport.com>
	<87r82cj9h6.fsf@zaphod.blackdown.de>
	<20030920172253.GD14640@perlsupport.com>
Reply-To: Juergen Kreileder <jk@blackdown.de>, 202756@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, 202756@bugs.debian.org
Return-path: <bounce-debian-glibc=debian-glibc=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.202756.B202756.106408089222715@bugs.debian.org>
To: Chip Salzenberg <chip@debian.org>
In-Reply-To: <20030920172253.GD14640@perlsupport.com> (Chip Salzenberg's
 message of "Sat, 20 Sep 2003 13:22:53 -0400")
List-Post: <mailto:debian-glibc@lists.debian.org>
List-Help: <mailto:debian-glibc-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-glibc-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-glibc-request@lists.debian.org?subject=unsubscribe>
List-Archive: <http://lists.debian.org/debian-glibc/>
List-ID: <nfs.lists.sourceforge.net>

Chip Salzenberg <chip@debian.org> writes:

> According to Juergen Kreileder:
>> Chip Salzenberg <chip@pobox.com> writes:
>>> * 1.0.6 does _not_ fix the crash.
>>> * preloading libpthread.so.0 is still an effective workaround
>>
>> Looks like a glibc problem, it's triggered by using lwres in
>> nsswitch.conf.  See
>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=211621
>
> Ah, that's excellent news from our end.
>
> Have you verified that avoiding lwres allows mountd to keep working?

Yes, mountd works fine when I disable lwres.


        Juergen

-- 
Juergen Kreileder, Blackdown Java-Linux Team
http://www.blackdown.org/java-linux/java2-status/
