From: Dave Ingram <davei@wolfram.com>
Subject: Re: recursive NFS export of mounted ISO images -- Automounter Maps?
Date: Wed, 23 Oct 2002 15:29:06 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210231520230.31286-100000@wopr.wolfram.com>
References: <1035404257.3db703e149b4b@webmail.smithconcepts.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wri-dns0.wolfram.com ([140.177.205.10] helo=wolfram.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184S8w-0007n1-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:30:18 -0700
To: "Bryan J. Smith" <b.j.smith@ieee.org>
In-Reply-To: <1035404257.3db703e149b4b@webmail.smithconcepts.com>
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

> Correct, because NFS will not cross filesystem boundaries (for various reasons).

	I understand. But I think it's odd that I did the following 
successfully:

1. Mounted 3 ISO images from the /Source partition to /Jukebox
2. Added entries for each of the /Jukebox/... directories into 'exports'
3. Reloaded NFS
4. Successfully NFS mounted and used the files from the server

	How is that possible if one cannot cross filesystem boundaries on 
the server side? The source partition is different than the destination 
partition.

> NIS Automounter Maps make this trivial for the clients.  You'll need to enable
> Automounter on the client too, which is even more trivial.

	Ah. That's provided that all your clients can deal with autofs. We 
have every *NIX flavor you can think of here. The single common 
denominator for them is NFS.

> I change my NIS Automounter Maps on-the-fly and it seems to get updated on my
> Linux and Solaris NIS/NFS clients without issue.

	Well, you're lucky - Linux and Solaris support autofs and have 
consistent mechanisms for configuring them. Some of our *NIX's either 
don't have anything like autofs/NIS or have completely different ways of 
configuring them.

> No, again, because NFS won't cross filesystems.

	I'm still confused then how I was able to perform the experiment 
quoted earlier. From all appearances, I *did* cross filesystems (which as 
I said confuses me greatly)

> Unless you have remote clients dynamically run "mkisofs," possibly with rsh/ssh
> commands.

	You're assuming again that all the client machines HAVE something 
even remotely like "mkisofs". A lot of them do not.

> In fact, you might be looking at this wrong.  I'd just plunk the files on the
> server, then make .iso files as necessary.  Especially if the CDs change regularly.

	Unfortunately that just isn't how our software engineering system 
works. SQA is explicit about having the files they test be directly FROM 
the ISO image. Burning many CDs every day and shuffling them around is a 
nightmare, which is why we're trying to do this.

> Also, I assume you've never messed with Automounter or NIS Automounter Maps, as
> it makes the NFS world so much easier.  Learn it and you'll wonder how you ever
> lived without it.

	No, I *have* worked with automounter, under Solaris several years 
ago.

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
