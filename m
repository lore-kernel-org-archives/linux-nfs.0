From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Killing lockd
Date: Thu, 28 Aug 2003 15:54:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16206.24064.388616.969526@charged.uio.no>
References: <20030828182808.GC1166@async.com.br>
	<shslltd4njk.fsf@charged.uio.no>
	<20030828193016.GA1513@async.com.br>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030828193016.GA1513@async.com.br>
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

    >> Alternatively, you would have to umount all the partitions that
    >> are running without 'nolock' set.

     > Hmmm. This isn't on a client, though, it's on a server - it
     > doesn't mount any foreign exports. Or did you literally mean
     > partitions?

If it's on the server, then you just need to kill the nfsds.

     > Now, pmap_dump/_set would have helped *if* I had known about
     > them previously to killing the portmapper <wink>

The pmap_dump format for files is the same as that returned by
rpcinfo. i.e. it is human-readable and can therefore be reconstructed
if you know which daemons are running on which ports.

'netstat -ap' is your friend (as is 'lsof').

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
