From: "Bryan J. Smith" <b.j.smith@ieee.org>
Subject: Re: recursive NFS export of mounted ISO images -- Automounter Maps?
Date: Wed, 23 Oct 2002 16:17:37 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035404257.3db703e149b4b@webmail.smithconcepts.com>
References: <Pine.LNX.4.44.0210231440430.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from knight.01.dios.net ([65.222.230.112] helo=taz2.fiberhosting.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184Rwo-0004Hl-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:17:46 -0700
To: Dave Ingram <davei@wolfram.com>
In-Reply-To: <Pine.LNX.4.44.0210231440430.31286-100000@wopr.wolfram.com>
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
> We have a huge RAID system that houses, among other things, many 
> ISO image files.
> The quality assurance people would like to have a "virtual 
> jukebox" that is distributed via NFS to our large array of test
> machines. 
> This jukebox would contain the mounted ISO images.
> However, currently there is no way to have a single parent 
> directory distributed over NFS that will propogate its mounted contents.

Correct, because NFS will not cross filesystem boundaries (for various reasons).

> One must currently define an explicit mount point in /etc/exports (eg:
> /Jukebox/M-LINUX-L/6.0.0/187885).

That's easy to automate with "sed."  You've probably want to setup Automounter
on the server as well, which is also trivial.

> Additionally, the client must know the explicit mount point to
> properly mount this shared image.
> This is a problem when you want to have several hundred (well, no 
> more than 255 theoretically because of the 8-bit 'minor' device issue
> with loop devices) ISO images that you'd like to distribute, because you
> then are responsible for maintaining EVERY explicit mount point for each
> image, both on the server and each client.

NIS Automounter Maps make this trivial for the clients.  You'll need to enable
Automounter on the client too, which is even more trivial.

> Even more frustrating is the fact that this is going to be an 
> automated dynamic process. That is - as ISO images are automatically
> built by other systems, we'll want to mount and export their contents 
> automatically. Likewise, we'll need to prune existing ISO images and
> their respective mounts.

Again, NIS Automounter Maps anyone???

> And, there is no way for the client-side to "know" each mount 
> point in an automated fashion. That is - if the ISO builder system 
> generates a new ISO image, mounts it, and distributes it, there is now a
> unique mount point that the client can't programatically determine.

I change my NIS Automounter Maps on-the-fly and it seems to get updated on my
Linux and Solaris NIS/NFS clients without issue.

> So - why the heck am I bothering NFS people with this?
> Because I am wondering if there is a way to simply have ONE mount 
> point exported and mounted on the client side, and have it recursively
> inherit each of the mounted image directories within it.

No, again, because NFS won't cross filesystems.

> Also - for those who are asking, "Hey dummy - why don't you just 
> mount the images on the NFS server, then copy their contents into
> /Jukebox in the appropriate directory?!". Well, because our quality
> assurance people would like to work with the EXACT files that are
> going to get burned to CD if the build is a success. Copying the
> files introduces an extra step that makes them nervous. Plus -
> every ISO image whose contents we must actually COPY means another
> 600+ megs we have to allocate disk to.

Unless you have remote clients dynamically run "mkisofs," possibly with rsh/ssh
commands.

In fact, you might be looking at this wrong.  I'd just plunk the files on the
server, then make .iso files as necessary.  Especially if the CDs change regularly.

> Thoughts, anyone?
> If all you can say is, "That's impossible" or "You're a moron" - 
> your reply will find its way into /dev/null. :-)

I might not be understanding exactly what you want to do, but I think you're
approaching this wrong.

Also, I assume you've never messed with Automounter or NIS Automounter Maps, as
it makes the NFS world so much easier.  Learn it and you'll wonder how you ever
lived without it.

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
