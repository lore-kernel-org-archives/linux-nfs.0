From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: Converting open filehandles to pathnames
Date: Mon, 10 May 2004 10:02:07 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405100933010.22462-100000@kenzo.iwr.uni-heidelberg.de>
References: <1084137085.715.26.camel@omikron>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Garrick Staples <garrick@usc.edu>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BN5k2-0000IV-TG
	for nfs@lists.sourceforge.net; Mon, 10 May 2004 01:02:26 -0700
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BN5k2-0008CB-Dg
	for nfs@lists.sourceforge.net; Mon, 10 May 2004 01:02:26 -0700
To: Erik Walthinsen <omega@pdxcolo.net>
In-Reply-To: <1084137085.715.26.camel@omikron>
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

On Sun, 9 May 2004, Erik Walthinsen wrote:

> The biggest challenge for general usage is the inode -> pathname
> translation.

Can't this be done quicker on the server ?

I'm not saying that the program should be run on the server because of 
this reason - only that if it's run on the server it might be more 
efficient. I see 2 situations here:
- when you have several clients and one server and wonder who is 
banging on the server - then you run the program on the server
- when you have several servers and wonder why has a client which
mounts FS-es from all a so high I/O-induced load - then you run the
program on the client

> Any other suggestions on how I can generically convert inodes to
> pathnames without massive overhead?

IMHO, the most important question is: do you want to convert _all_
inodes back to pathnames ? For example, what I'm interested in is the
cases where a process has one or a few large files open that are
accessed over and over again. I'm not at all interested in finding out
the pathnames of all the files in a source directory which will be
read exactly once during the build process and those of the
corresponding object files that will be written to, also exactly once.
Each source/object file can be transferred as one or more NFS chunks,
depending on the file size and the NFS chunk size. So I propose to
make some kind of caching and counting of the filehandles and only if
the same filehandle was present in a certain number of NFS chunks
should the program attempt to get the corresponding pathname.
However, by setting this number to something low (even 1), the admin 
can also see such kind of accessed-once files.
Also, there should be a cache of already converted filenames, such 
that accessing a file often does not result in many conversions; from 
what you wrote, it appears that you are already doing this, only that 
the cache is filled at startup (and probably never deleted from) 
rather than dynamically at runtime. But be careful here: as the cache 
grows, so is the time needed to check if the entry is cached or not up 
to the point that it might be faster to do a new conversion.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
