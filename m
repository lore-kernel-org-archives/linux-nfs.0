From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: [PATCH] 2.4.19-pre10 RPC changes...
Date: Mon, 8 Jul 2002 10:31:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D086@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RcM6-0002GA-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Jul 2002 10:31:22 -0700
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

> On Tuesday 02 July 2002 19:59, Lever, Charles wrote:
> 
> > yes.  fix_refresh + fix_kmap1 hangs under stress on my system.
> >
> > i can reproduce this with "make -j2 bzImage" in one window
> > and "bonnie" in a loop in another.  both cwd's are in the
> > same TCP-mounted NFS file system.
> 
> Is this with CONFIG_HIGHMEM set (you didn't specify your 
> .config) and does it only happen on TCP mounts?

my bad... yes, this is a 1GB system, so HIGHMEM is set, and
yes, the file system is a TCP file system.

> If so, then the appended bugfix might help...

i tested today against 2.4.19-rc1 with fix-kmap1 applied.
it appeared to have the previously attached fix in it
already.

i was not able to deadlock my system.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
