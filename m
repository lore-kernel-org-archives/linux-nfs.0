From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: executable but not readable
Date: Fri, 26 Mar 2004 14:17:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080328671.2480.23.camel@lade.trondhjem.org>
References: <40631E32.1020707@gsi.de>
	 <1080239856.2584.18.camel@lade.trondhjem.org>  <40640A7E.5040601@gsi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6wqg-0005Xo-W7
	for nfs@lists.sourceforge.net; Fri, 26 Mar 2004 11:18:34 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B6wqg-0000pJ-NS
	for nfs@lists.sourceforge.net; Fri, 26 Mar 2004 11:18:34 -0800
To: Christopher Huhn <C.Huhn@gsi.de>
In-Reply-To: <40640A7E.5040601@gsi.de>
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

P=E5 fr , 26/03/2004 klokka 05:48, skreiv Christopher Huhn:
> The point is that I'm not talking about (ELF) executables but shell
> scripts!=20
> IMHO in local semantics the shell interpreter cannot execute scripts
> the executor has not read permissions for (How should he without
> beeing setuid root?).

That is irrelevant: the server knows nothing about the existence of
shell scripts. The point in the RFC is that the server should be looking
at both the "executable" and the "read" bits when deciding whether or
not to grant read access to the client.

In NFSv3, the ACCESS call should then be used to decide whether or not
the client is allowed to open the file for execution (and for reading if
that is required). Unfortunately ACCESS is not implemented in the stock
Linux 2.4.x kernel.
Otherwise the client can only look at the mode bits in order to try to
make the same decision. Of course that will fail to work properly anyway
if the server has a different uid/gid mapping scheme to the client.

However if you really want to prevent OTHER+GROUP from reading and
executing your shell scripts, then "chmod 500 /bin/ls.sh" is your
simplest solution. That does the same thing on both the local and remote
filesystems.

Cheers,
 Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
