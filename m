From: James Pearson <james-p@moving-picture.com>
Subject: Re: Problems building nfs-utils 0.3.3
Date: Mon, 15 Apr 2002 10:18:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CBA9AE2.9080597C@moving-picture.com>
References: <20020413074001.A6404@server.sunrise-linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16x2dO-0006tt-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Apr 2002 02:18:50 -0700
To: miah <jjohnson@sunrise-linux.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

miah wrote:
> 
> Hi all,
> 
> I'm not really sure why, but nfs-utils has stopped compiling for us.  If we had the time to fully look into this issue we would.  I tried the latest cvs version, but that appears to have the same problem too.  Attached is our build log, if anybody can shed some light on this, we'd appreciate it.
> 

Not an expert on this sort of thing, but:

> Making all in export
> rm -f mount.h mount_clnt.c mount_xdr.c
> ../../bin/rpcgen -h -o mount.h mount.x
> cannot find any C preprocessor (cpp)
> ../../bin/rpcgen -l -o mount_clnt.c mount.x
> cannot find any C preprocessor (cpp)
> ../../bin/rpcgen -c -o mount_xdr.c mount.x
> cannot find any C preprocessor (cpp)

looks like is part of the problem ...

Do you have /lib/cpp (which on my systems is a symbolic link to
/usr/bin/cpp) ?

James Pearson

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
