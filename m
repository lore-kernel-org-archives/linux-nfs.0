From: "Bryan J. Smith" <b.j.smith@ieee.org>
Subject: Re: Re: recursive NFS export of mounted ISO images -- Automounter Maps?
Date: Wed, 23 Oct 2002 17:18:31 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035407911.3db71227b92f3@webmail.smithconcepts.com>
References: <Pine.LNX.4.44.0210231543580.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Bryan J. Smith" <b.j.smith@ieee.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from knight.01.dios.net ([65.222.230.112] helo=taz2.fiberhosting.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184Sth-0005Vv-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 14:18:37 -0700
To: Dave Ingram <davei@wolfram.com>
In-Reply-To: <Pine.LNX.4.44.0210231543580.31286-100000@wopr.wolfram.com>
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


Quoting Dave Ingram <davei@wolfram.com>:
> Hmmmm. Has it always been in IRIX? I can't find it on our 6.3 
> machine. I see you are correct that it's on AIX - I missed it earlier.
> And it's on HP-UX. So - perhaps I stand corrected. :-P

I apologize since I haven't touched Irix since 1999, but I was fairly certain my
Irix 6.x systems had it.  Now they _do_ sell NIS/NFS as a separate add-on which
we _did_ buy, but that was just the server.  I thought the clients came standard.

> I'm still a little fuzzy on this, sorry.  Is the loopback mount the 
> key here?

You essentially need both.  The loopback mount, since that's what is what you
are browsing, and the filesystem with the .iso files, because 

> Wow. I haven't seen it work on HP-UX or Tru64. Maybe I'm missing 
> something.

I've always been able to find binaries.

> I misunderstood you, sorry.

There's a million ways to run something on a server, but write to a client. 
Remember, you're using UNIX.  ;-P

> I certainly won't argue with you. I think, however, sanity issues 
> aside, we're still contending with a large pool of ISO images.
> We have several hundred gigabytes in this part of the array to play
> with, of course, but I like to avoid unnecessary (but maybe it IS
> necessary) copying of things when I can. Especially when it sucks
> space aggressively.
> Well, it's come a long way. I'm not in QA, but my group has 
> greatly reduced the number of physical CD's that get tossed around.
> We're trying to get it to where the only time anybody should be
> burning CDs is for an alpha or beta candidate.

Again, I think the QA department has a "false sense" of a loopback mounted .iso
file being the exact same as a CD.  Heck, dd a CD then dd an .iso file -- not
the same because an .iso file is just the data track format for ISO9660 Yellow
Book, not the entire CD.

> Here's all the things we've got here:
> Linux (x86, PPC, Alpha, Itanium [soon Itanium2])

NIS, Autofs, NSSwitch all there.

> Mac OS/X (well okay it's not really UNIX)

Hmmm, not sure there though.  BSD has an automounter, or maybe you've gotta get
amd working?

> HP-UX (10.x, 11.x)

I've only limited experience with HP-UX (1995 timeframe).

> AIX (4.x, 5.x)

All there.

> Tru64 (5.x)

All there.

> Solaris (2.5, 2.6, 7, 8, 9)

The original GNU platform (I love how the media "trips over itself" wondering
why Sun is so much like Linux ;-).

> IRIX

Again, they should be available there too.

> Hmmm - I guess that's not TOO many. Nonetheless, it's a rather 
> diverse bunch. IRIX and Linux-PPC (and Alpha) are going away soon
> (here, that is).

Linux/Alpha has always been the engineer's dream platform.  UNIX on an
ultra-anal RISC platform.  Ahhh ...

-- 
Bryan J. Smith, E.I.            Contact Info:  http://thebs.org
A+/i-Net+/Linux+/Network+/Server+ CCNA CIWA CNA SCSA/SCWSE/SCNA
---------------------------------------------------------------
           limit      guilt   =     { psychopath,
         remorse->0                    innocent }



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
