From: Erik Walthinsen <omega@pdxcolo.net>
Subject: Re: Converting open filehandles to pathnames
Date: Mon, 10 May 2004 07:20:21 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084198818.711.5.camel@omikron>
References: <Pine.LNX.4.44.0405100933010.22462-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BNIVh-0004jx-5g
	for nfs@lists.sourceforge.net; Mon, 10 May 2004 14:40:29 -0700
Received: from [216.99.212.251] (helo=mail.omegacs.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BNIVg-000795-P0
	for nfs@lists.sourceforge.net; Mon, 10 May 2004 14:40:28 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0405100933010.22462-100000@kenzo.iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, 2004-05-10 at 01:02, Bogdan Costescu wrote:
> Can't this be done quicker on the server ?
I never specified one way or another, but yes, this is done on the
server.

However, it doesn't change the problem that in order to do an
inode->pathname translation, without some tricks I don't know about, you
have to stat() every single file on the entire filesystem.  Yes, this is
faster on the server, I never considered running such a search from a
client.

The only hack I can think of would be if the server is running ext3 or
some other filesystem with a debugger, and see if it's possible to
perform the reverse mapping that way, quickly.  Very much not my
favorite option though.

> IMHO, the most important question is: do you want to convert _all_
> inodes back to pathnames ? For example, what I'm interested in is the
> cases where a process has one or a few large files open that are
> accessed over and over again. I'm not at all interested in finding out
> the pathnames of all the files in a source directory which will be
> read exactly once during the build process and those of the
> corresponding object files that will be written to, also exactly once.
> Each source/object file can be transferred as one or more NFS chunks,
> depending on the file size and the NFS chunk size. So I propose to
> make some kind of caching and counting of the filehandles and only if
> the same filehandle was present in a certain number of NFS chunks
> should the program attempt to get the corresponding pathname.
> However, by setting this number to something low (even 1), the admin 
> can also see such kind of accessed-once files.
OK, that can be done fairly easily, esp with Python.

> Also, there should be a cache of already converted filenames, such 
> that accessing a file often does not result in many conversions; from 
> what you wrote, it appears that you are already doing this, only that 
> the cache is filled at startup (and probably never deleted from) 
> rather than dynamically at runtime. But be careful here: as the cache 
> grows, so is the time needed to check if the entry is cached or not up 
> to the point that it might be faster to do a new conversion.
The cache I create is static because new files are *extremely* rare. 
Because I don't have more than 1k files currently, performance
optimizations will likely be someone else's modification to the script
once I've got it built.



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
