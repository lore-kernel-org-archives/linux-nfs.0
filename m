From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: userspace NFS daemon
Date: Mon, 6 Sep 2004 21:35:28 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409062120550.19152-100000@kenzo.iwr.uni-heidelberg.de>
References: <1094441577.10492.134.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Frank van Maarseveen <frankvm@xs4all.nl>,
        Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4PHF-0006AE-0A
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 12:35:45 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4PHD-00042O-4p
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 12:35:44 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094441577.10492.134.camel@lade.trondhjem.org>
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

On Sun, 5 Sep 2004, Trond Myklebust wrote:

> No. I mean that very few people have ever used unfsd in mission-critical
> production environments.

Well, I don't know what your standards are relative to
"mission-critical", but some years ago knfsd didn't exist and
clustering people (among others) had to use the user-level daemon(s)  
for everything anyway. Some preferred to continue this way... (I'm not 
among them though).

> If you have to mount all the writeable partitions separately from a more
> robust server, then why bother?

/tmp is usually a local disk, not another NFS server. For /var things 
are not so clear though, but if you have a heavy-written /var 
partition then NFS (even with knfsd) might not be the best solution 
anyway - a parallel FS that would share the disk bandwidth might be 
better even than local disk (and might provide better reliability...)

> Replicating /etc and changing the two or three files that differ for
> each cluster node is hardly a difficult task: you can do it using a
> simple shell script. /bin doesn't even have to be replicated...

As in Unix tradition, there are several ways to achieve the same goal.  
There are people using 'mount -o bind' (like RHEL's diskless booting
setup procedure) or hard-links (what I use). But both of these require
some maintenance effort in form of scripts and a general cleanliness
in handling software updates or new installs. With clusternfs, the
files are created in their place with their intended destination in
the name and the daemon takes care of the rest... There are people
that prefer to concentrate on science rather than system
administration. :-)

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
