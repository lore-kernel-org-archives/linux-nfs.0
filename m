From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re[2]: Linux NFS Implementation
Date: 06 May 2002 11:45:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsit61pq2l.fsf@charged.uio.no>
References: <6550723576.20020505124553@netzone.ch>
	<shs8z6ykfki.fsf@charged.uio.no>
	<1427145935.20020506000801@netzone.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174f42-0000vx-00
	for <nfs@lists.sourceforge.net>; Mon, 06 May 2002 02:45:50 -0700
To: Gavin Woodhatch <gavin.woodhatch@netzone.ch>
In-Reply-To: <1427145935.20020506000801@netzone.ch>
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

>>>>> " " == Gavin Woodhatch <gavin.woodhatch@netzone.ch> writes:

     > Trond Myklebust wrote:
    >> > Hello All Are all NFSv3 Fuctions Implemented in Linux (like
    >> > readdirplus) ?
    >>
    >> Are you talking about the client or the server?


     > Hello Trond, i meant the client, sorry for not being more
     > clear.

READDIRPLUS is not yet implemented. I have patches on

   http://www.fys.uio.no/~trondmy/src/<kernel_version>

that do so, but they have not been merged into the kernel.

There is also some work to be done in order to implement proper
versions of NFSv3 exclusive open, and the ACCESS call, but those will
both probably require VFS changes...

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
