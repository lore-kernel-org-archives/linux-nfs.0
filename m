From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: [PATCH] 2.4.19-pre10 RPC changes...
Date: Tue, 2 Jul 2002 10:59:29 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D06E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17PRwN-0002hG-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Jul 2002 10:59:51 -0700
To: "'Trond Myklebust'" <trond.myklebust@fys.uio.no>
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

> On Saturday 29 June 2002 20:53, Chuck Lever wrote:
> > i'm able to deadlock my dual 1.26GHz P-III with just these 
> patches applied
> > to a naked 2.4.19-pre10 kernel:
> >
> > linux-2.4.19-00-fix_refresh.dif
> > linux-2.4.19-01-fix_kmap1.dif
> > linux-2.4.19-02-fix_kmap2.dif
> > linux-2.4.19-03-fix_kmap3.dif
> 
> Any chance of finding out which one of the 3 kmap patches is 
> the one giving trouble?

yes.  fix_refresh + fix_kmap1 hangs under stress on my system.

i can reproduce this with "make -j2 bzImage" in one window
and "bonnie" in a loop in another.  both cwd's are in the
same TCP-mounted NFS file system.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
