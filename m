From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] better RPC statistics
Date: 08 Oct 2002 23:57:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1034117863.31448.30.camel@irongate.swansea.linux.org.uk>
References: <Pine.LNX.4.44.0210081517370.1273-100000@dexter.citi.umich.edu>
	 <20021008220450.GC9807@think.thunk.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <cel@citi.umich.edu>, Linus Torvalds <torvalds@transmeta.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc1-cwma1-5-cust42.swa.cable.ntl.com ([80.5.120.42] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z38c-0006w0-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 15:47:38 -0700
To: "Theodore Ts'o" <tytso@mit.edu>
In-Reply-To: <20021008220450.GC9807@think.thunk.org>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Tue, 2002-10-08 at 23:04, Theodore Ts'o wrote:
> It's not just "kernel interfaces" which should go in before October
> 20th.  
> 
> If we really want the feature freeze to be real, we really will need
> to be hard-nosed about what we accept after the freeze date.  (Said he
> who is frantically trying to finish up a last couple of ext2/3
> features in before 2.6.)
> 
> So I'd encourage folks to at least submit patches before Oct. 20th
> when they are ready, and not try to save stuff for after feature
> freeze....

There is a lot of driver clean up which will take lots of time beyond
Oct 31st. IDE is going to take a whole ton of work yet, but that (well
barring what happens with driverfs now) should be independant of the
rest of the world.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
