From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: userspace NFS daemon
Date: Sun, 05 Sep 2004 23:32:57 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094441577.10492.134.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0409060210030.12696-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Frank van Maarseveen <frankvm@xs4all.nl>, Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4AFp-00064K-FV
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 20:33:17 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4AFm-0005VW-5j
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 20:33:17 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0409060210030.12696-100000@kenzo.iwr.uni-heidelberg.de>
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

P=E5 su , 05/09/2004 klokka 20:47, skreiv Bogdan Costescu:

> Err, you mean to say that root-NFS only appeared after knfsd ? And=20
> that knfsd was absolutely flawless since day 1 ? :-)

No. I mean that very few people have ever used unfsd in mission-critical
production environments.
You might get away with it for read-only stuff (if you are prepared to
put up with the speed), but nobody should be using it for read/write
partitions.

> Cluster nodes have usually a small number of software packages=20
> installed. Most "core" packages (like core-utils, grep, gawk, etc.)=20
> don't need locking. As / doesn't see itself much writting (which=20
> happens usually in /var and /tmp, but those can be mounted=20
> separately), NFSv3 vs. NFSv2 doesn't make much difference either. So=20
> what's the problem with using unfsd in these conditions ?

If you have to mount all the writeable partitions separately from a more
robust server, then why bother? Replicating /etc and changing the two or
three files that differ for each cluster node is hardly a difficult
task: you can do it using a simple shell script. /bin doesn't even have
to be replicated...

The "per-uid" and "per-gid" stuff might be more useful, but is likely to
be defeated by lookup caching rules on most NFS clients.

Note: the premise:
        If a matching file is located, but authorization is denied,this
        is NOT considered a match, and the next entry on the list will
        be attempted.
if taken literally, would certainly make managing these name.ipaddress
files "interesting": "chmod a+r,a-w blah; cat >blah" might have some
curious side-effects...

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
