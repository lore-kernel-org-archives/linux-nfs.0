From: miah <jjohnson@sunrise-linux.com>
Subject: Re: Problems building nfs-utils 0.3.3
Date: Mon, 15 Apr 2002 07:11:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020415071116.B50298@server.sunrise-linux.com>
References: <20020413074001.A6404@server.sunrise-linux.com> <3CBA9AE2.9080597C@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [198.78.66.27] (helo=server.sunrise-linux.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16x7CR-00052a-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Apr 2002 07:11:19 -0700
Received: (from miah@localhost)
	by server.sunrise-linux.com (8.11.6/8.11.6) id g3FEBGM56184
	for nfs@lists.sourceforge.net; Mon, 15 Apr 2002 07:11:16 -0700 (PDT)
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

Actually, after some checking, my patch is fine.  Its nfs-utils that is broke.  Exerpt from tools/rpcgen/rcp_main.c:

tatic svc_output();
 */

#define EXTEND  1               /* alias for TRUE */
#define DONT_EXTEND     0               /* alias for FALSE */

#define SVR4_CPP "/usr/ccs/lib/cpp"
#define SUNOS_CPP "/lib/cpp"
static int cppDefined = 0;          /* explicit path for C preprocessor */


static char *cmdname;

As we see here, its being defined in what I belive to be a inccorect way.  I guess if code is to be "Sun OS compatible" it might need to be defined this way, but im sure a configure option could set this properly.  For a Linux system though, if its to be FHS compliant, it shouldn't have a cpp in /lib, and it shouldnt have a /usr/ccs/lib dir.

Obviously the patch for me is simple here.  Hope a fix for this gets in CVS.

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
