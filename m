From: Chip Salzenberg <chip@debian.org>
Subject: Re: [jk@blackdown.de: Re: Bug#202756: nfs-kernel-server: 1.0.5-1 works with libc6 from unstable but fails with libc6 2.3.2-1 from experimental]
Date: Sat, 20 Sep 2003 13:22:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030920172253.GD14640@perlsupport.com>
References: <20030915021427.GA8188@perlsupport.com> <87r82cj9h6.fsf@zaphod.blackdown.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, 202756@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0lRt-0007pm-00
	for <nfs@lists.sourceforge.net>; Sat, 20 Sep 2003 10:23:09 -0700
Received: from topaz.cx
	([66.220.6.227] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A0lRs-0008Ku-Gi
	for nfs@lists.sourceforge.net; Sat, 20 Sep 2003 10:23:08 -0700
To: Juergen Kreileder <jk@blackdown.de>
In-Reply-To: <87r82cj9h6.fsf@zaphod.blackdown.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

According to Juergen Kreileder:
> Chip Salzenberg <chip@pobox.com> writes:
> > * 1.0.6 does _not_ fix the crash.
> > * preloading libpthread.so.0 is still an effective workaround
> 
> Looks like a glibc problem, it's triggered by using lwres in nsswitch.conf.
> See http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=211621

Ah, that's excellent news from our end.

Have you verified that avoiding lwres allows mountd to keep working?
Or is that not a practical test for you?
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
