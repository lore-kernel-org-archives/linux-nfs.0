From: Christian Reis <kiko@async.com.br>
Subject: Re: Killing lockd
Date: Thu, 28 Aug 2003 16:30:16 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030828193016.GA1513@async.com.br>
References: <20030828182808.GC1166@async.com.br> <shslltd4njk.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shslltd4njk.fsf@charged.uio.no>
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

On Thu, Aug 28, 2003 at 02:58:23PM -0400, Trond Myklebust wrote:
> >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> 
>      > Is there a way to kill lockd, or to tell it to restart and
>      > register again in the portmapper? I do know that something (or
>      > maybe it's suicide) tries to wait for lockd to die upon
>      > shutting down on our diskless network, without success. Any
>      > hints?
> 
> Why can't you use pmap_dump + pmap_set? The above type of recovery
> situation is exactly what they have been developed for.
> 
> Alternatively, you would have to umount all the partitions that are
> running without 'nolock' set.

Hmmm. This isn't on a client, though, it's on a server - it doesn't
mount any foreign exports. Or did you literally mean partitions?

Now, pmap_dump/_set would have helped *if* I had known about them
previously to killing the portmapper <wink>

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
