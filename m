From: Dave Ingram <davei@wolfram.com>
Subject: recursive NFS export of mounted ISO images
Date: Wed, 23 Oct 2002 14:51:49 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210231440430.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wri-dns0.wolfram.com ([140.177.205.10] helo=wolfram.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184RYz-0001HT-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 12:53:10 -0700
Received: from wopr.wolfram.com (wopr.wolfram.com [140.177.10.29])
	by wolfram.com (8.11.2/8.11.2) with ESMTP id g9NJqug16646
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 14:52:56 -0500
Received: from localhost (davei@localhost)
	by wopr.wolfram.com (8.11.6/8.11.6) with ESMTP id g9NJpnN31823
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 14:51:49 -0500
To: nfs@lists.sourceforge.net
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


	Hello, we're trying to do something a little odd in NFS that I 
don't believe is currently possible. However, I have seen in the mail 
archives that Neil Brown discussed this back in 7-4-2001.

	The problem is this:

	We have a huge RAID system that houses, among other things, many 
ISO image files.

	The quality assurance people would like to have a "virtual 
jukebox" that is distributed via NFS to our large array of test machines. 
This jukebox would contain the mounted ISO images.

	However, currently there is no way to have a single parent 
directory distributed over NFS that will propogate its mounted contents. 
One must currently define an explicit mount point in /etc/exports (eg: 
/Jukebox/M-LINUX-L/6.0.0/187885). Additionally, the client must know the 
explicit mount point to properly mount this shared image.

	This is a problem when you want to have several hundred (well, no 
more than 255 theoretically because of the 8-bit 'minor' device issue with 
loop devices) ISO images that you'd like to distribute, because you then 
are responsible for maintaining EVERY explicit mount point for each image, 
both on the server and each client.

	Even more frustrating is the fact that this is going to be an 
automated dynamic process. That is - as ISO images are automatically built 
by other systems, we'll want to mount and export their contents 
automatically. Likewise, we'll need to prune existing ISO images and their 
respective mounts.

	And, there is no way for the client-side to "know" each mount 
point in an automated fashion. That is - if the ISO builder system 
generates a new ISO image, mounts it, and distributes it, there is now a 
unique mount point that the client can't programatically determine.

	So - why the heck am I bothering NFS people with this?

	Because I am wondering if there is a way to simply have ONE mount 
point exported and mounted on the client side, and have it recursively 
inherit each of the mounted image directories within it.

	Also - for those who are asking, "Hey dummy - why don't you just 
mount the images on the NFS server, then copy their contents into /Jukebox 
in the appropriate directory?!". Well, because our quality assurance 
people would like to work with the EXACT files that are going to get 
burned to CD if the build is a success. Copying the files introduces an 
extra step that makes them nervous. Plus - every ISO image whose contents 
we must actually COPY means another 600+ megs we have to allocate disk to.

	Thoughts, anyone?

	If all you can say is, "That's impossible" or "You're a moron" - 
your reply will find its way into /dev/null. :-)

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
