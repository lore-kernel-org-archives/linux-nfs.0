From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: questions about rpc and locks
Date: 01 May 2002 14:14:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7qoqd4f.fsf@charged.uio.no>
References: <20020430174511.A21356@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 172t1o-0008KV-00
	for <nfs@lists.sourceforge.net>; Wed, 01 May 2002 05:16:13 -0700
To: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
In-Reply-To: <20020430174511.A21356@zeus.centre-cired.fr>
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

>>>>> " " == Patrice DUMAS <dumas@centre-cired.fr> writes:

     > Hi, I have 2 questions about the kernel rpc implementation.

     > 1. What are the return codes (from rpc_call) and their meanings
     >    (or where could I find that, I found that looking at the
     >    code itself was really hard).

For an ordinary synchronous call, rpc_call() returns the value of
task->tk_status upon exit.

If the call could not be made, then that value will reflect an error
code, usually EINTR (although for 'soft' RPC calls, the error EIO will
be returned if a major timeout occurred).

If the call was made, then the value is set by the XDR decode entry
(see the macro rpcproc_decode(clnt, task->tk_msg.rpc_proc)) if it
exists in the 'struct rpc_procinfo' table.

If the server is not expected to return a value, then the
corresponding XDR decode entry should be NULL, and task->tk_status
should normally be zero upon rpc_call exit.

     > 2. Is it possible to know at what point the rpc call failed ? 
     >    (from within the rpc_task struct, to determine whether the
     >    caller couldn't send or it didn't get a response).

Only makes sense for 'soft' RPC calls, and in that case you get an EIO.

     > 3. When the client think it has a lock on a nfs file, but the
     >    server thinks the client hasn't, what happens ?

File corruption is possible, and the server will return
'NLM_LCK_DENIED_NOLOCKS' when the client tries to unlock.

Cheers,
  Trond
