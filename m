From: miah <jjohnson@sunrise-linux.com>
Subject: Re: Problems building nfs-utils 0.3.3
Date: Mon, 15 Apr 2002 06:59:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020415065910.A50298@server.sunrise-linux.com>
References: <20020413074001.A6404@server.sunrise-linux.com> <3CBA9AE2.9080597C@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [198.78.66.27] (helo=server.sunrise-linux.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16x70g-00034c-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Apr 2002 06:59:10 -0700
Received: (from miah@localhost)
	by server.sunrise-linux.com (8.11.6/8.11.6) id g3FDxAw52421
	for nfs@lists.sourceforge.net; Mon, 15 Apr 2002 06:59:10 -0700 (PDT)
	(envelope-from miah)
To: nfs@lists.sourceforge.net
In-Reply-To: <3CBA9AE2.9080597C@moving-picture.com>; from james-p@moving-picture.com on Mon, Apr 15, 2002 at 10:18:26AM +0100
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

I actually patched rpcgen to look for cpp in the proper place (/usr/bin) (I really with the glibc people would get with it..) But for some reason creating a symlink in /lib to /usr/bin/cpp fixes the build.  I guess I'll have to double check my rpcgen patch to make sure its working properly.

Thanks for pointing this out, I've been looking at this problem for longer than I had hoped and missed this.

-miah

On Mon, Apr 15, 2002 at 10:18:26AM +0100, James Pearson wrote:
> Not an expert on this sort of thing, but:
> 
> > Making all in export
> > rm -f mount.h mount_clnt.c mount_xdr.c
> > ../../bin/rpcgen -h -o mount.h mount.x
> > cannot find any C preprocessor (cpp)
> > ../../bin/rpcgen -l -o mount_clnt.c mount.x
> > cannot find any C preprocessor (cpp)
> > ../../bin/rpcgen -c -o mount_xdr.c mount.x
> > cannot find any C preprocessor (cpp)
> 
> looks like is part of the problem ...
> 
> Do you have /lib/cpp (which on my systems is a symbolic link to
> /usr/bin/cpp) ?
> 
> James Pearson
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
