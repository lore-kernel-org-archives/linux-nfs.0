From: Dave Ingram <davei@wolfram.com>
Subject: Re: recursive NFS export of mounted ISO images -- Automounter Maps?
Date: Wed, 23 Oct 2002 15:55:13 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210231543580.31286-100000@wopr.wolfram.com>
References: <1035405853.3db70a1d229ae@webmail.smithconcepts.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wri-dns0.wolfram.com ([140.177.205.10] helo=wolfram.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184SYF-0000qe-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:56:27 -0700
To: "Bryan J. Smith" <b.j.smith@ieee.org>
In-Reply-To: <1035405853.3db70a1d229ae@webmail.smithconcepts.com>
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

On Wed, 23 Oct 2002, Bryan J. Smith wrote:

> > Ah. That's provided that all your clients can deal with autofs. We 
> > have every *NIX flavor you can think of here. The single common 
> > denominator for them is NFS.
> > Well, you're lucky - Linux and Solaris support autofs and have 
> > consistent mechanisms for configuring them. Some of our *NIX's either 
> > don't have anything like autofs/NIS or have completely different ways of
> > configuring them.
> 
> Really?  I've messed with AIX and Irix too and it had both as well.

	Hmmmm. Has it always been in IRIX? I can't find it on our 6.3 
machine. I see you are correct that it's on AIX - I missed it earlier. And 
it's on HP-UX. So - perhaps I stand corrected. :-P

> > I'm still confused then how I was able to perform the experiment 
> > quoted earlier. From all appearances, I *did* cross filesystems (which
> > as I said confuses me greatly)
> 
> If you mount _both_ the .iso source _and_ the loopback mount, it _will_ work.

	I'm still a little fuzzy on this, sorry. Is the loopback mount the 
key here?

> First off, mkisofs runs on _everything_ I've seen, even Windows.

	Wow. I haven't seen it work on HP-UX or Tru64. Maybe I'm missing 
something.

> Secondly, run "mkisofs" on the server, but write on the client.

	I misunderstood you, sorry.

> > Unfortunately that just isn't how our software engineering system 
> > works. SQA is explicit about having the files they test be directly
> > FROM the ISO image.
> 
> As an engineer myself, used to working in production testing environments, I
> find this logic rather flawed.  You aren't really running from the .iso image
> anyway.  ;-P

	I certainly won't argue with you. I think, however, sanity issues 
aside, we're still contending with a large pool of ISO images. We have 
several hundred gigabytes in this part of the array to play with, of 
course, but I like to avoid unnecessary (but maybe it IS necessary) 
copying of things when I can. Especially when it sucks space aggressively.

> > Burning many CDs every day and shuffling them around is a
> > nightmare, which is why we're trying to do this.
> 
> Again, I think your QA process is not exactly true.

	Well, it's come a long way. I'm not in QA, but my group has 
greatly reduced the number of physical CD's that get tossed around. We're 
trying to get it to where the only time anybody should be burning CDs 
is for an alpha or beta candidate.

> What UNIX client flavors are you running anyway?

	Here's all the things we've got here:

Linux (x86, PPC, Alpha, Itanium [soon Itanium2])
Mac OS/X (well okay it's not really UNIX)
HP-UX (10.x, 11.x)
AIX (4.x, 5.x)
Tru64 (5.x)
Solaris (2.5, 2.6, 7, 8, 9)
IRIX

	Hmmm - I guess that's not TOO many. Nonetheless, it's a rather 
diverse bunch. IRIX and Linux-PPC (and Alpha) are going away soon (here, 
that is).

Dave

-- 
Dave Ingram
Tools and Automation Engineer
Wolfram Research
217-398-0700 x776



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
