From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: recursive NFS export of mounted ISO images
Date: 23 Oct 2002 16:07:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035403220.2880.196.camel@localhost>
References: <Pine.LNX.4.44.0210231440430.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.20.6.213] (helo=HPTI_MAIN.hpti.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184RsM-00018i-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:13:10 -0700
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

The April Linux Journal had an article on building a virtual CD-ROM
jukebox, and is available here.  It sounds a bit like what you are
looking for.  It's available here: 
http://www.linuxjournal.com/article.php?sid=5639

I don't recall whether it addresses the issues you bring up, but it
might.

dbr

On Wed, 2002-10-23 at 15:51, Dave Ingram wrote:
> 	Hello, we're trying to do something a little odd in NFS that I 
> don't believe is currently possible. However, I have seen in the mail 
> archives that Neil Brown discussed this back in 7-4-2001.
> 
> 	The problem is this:
> 
> 	We have a huge RAID system that houses, among other things, many 
> ISO image files.
> 
> 	The quality assurance people would like to have a "virtual 
> jukebox" that is distributed via NFS to our large array of test machines. 
> This jukebox would contain the mounted ISO images.
> 
> 	However, currently there is no way to have a single parent 
> directory distributed over NFS that will propogate its mounted contents. 
> One must currently define an explicit mount point in /etc/exports (eg: 
> /Jukebox/M-LINUX-L/6.0.0/187885). Additionally, the client must know the 
> explicit mount point to properly mount this shared image.
> 
> 	This is a problem when you want to have several hundred (well, no 
> more than 255 theoretically because of the 8-bit 'minor' device issue with 
> loop devices) ISO images that you'd like to distribute, because you then 
> are responsible for maintaining EVERY explicit mount point for each image, 
> both on the server and each client.
> 
> 	Even more frustrating is the fact that this is going to be an 
> automated dynamic process. That is - as ISO images are automatically built 
> by other systems, we'll want to mount and export their contents 
> automatically. Likewise, we'll need to prune existing ISO images and their 
> respective mounts.
> 
> 	And, there is no way for the client-side to "know" each mount 
> point in an automated fashion. That is - if the ISO builder system 
> generates a new ISO image, mounts it, and distributes it, there is now a 
> unique mount point that the client can't programatically determine.
> 
> 	So - why the heck am I bothering NFS people with this?
> 
> 	Because I am wondering if there is a way to simply have ONE mount 
> point exported and mounted on the client side, and have it recursively 
> inherit each of the mounted image directories within it.
> 
> 	Also - for those who are asking, "Hey dummy - why don't you just 
> mount the images on the NFS server, then copy their contents into /Jukebox 
> in the appropriate directory?!". Well, because our quality assurance 
> people would like to work with the EXACT files that are going to get 
> burned to CD if the build is a success. Copying the files introduces an 
> extra step that makes them nervous. Plus - every ISO image whose contents 
> we must actually COPY means another 600+ megs we have to allocate disk to.
> 
> 	Thoughts, anyone?
> 
> 	If all you can say is, "That's impossible" or "You're a moron" - 
> your reply will find its way into /dev/null. :-)
> 
> Dave
> 
> -- 
> Dave Ingram
> Tools and Automation Engineer
> Wolfram Research
> 217-398-0700 x776
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: Influence the future 
> of Java(TM) technology. Join the Java Community 
> Process(SM) (JCP(SM)) program now. 
> http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
-- 
David B. Ritch
High Performance Technologies, Inc.



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
