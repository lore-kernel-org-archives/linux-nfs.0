From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Killing lockd
Date: 28 Aug 2003 14:58:23 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslltd4njk.fsf@charged.uio.no>
References: <20030828182808.GC1166@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030828182808.GC1166@async.com.br>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Christian Reis <kiko@async.com.br> writes:

     > Is there a way to kill lockd, or to tell it to restart and
     > register again in the portmapper? I do know that something (or
     > maybe it's suicide) tries to wait for lockd to die upon
     > shutting down on our diskless network, without success. Any
     > hints?

Why can't you use pmap_dump + pmap_set? The above type of recovery
situation is exactly what they have been developed for.

Alternatively, you would have to umount all the partitions that are
running without 'nolock' set.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
