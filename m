From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: questions about rpc and locks
Date: 03 May 2002 09:41:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuul3cg4.fsf@charged.uio.no>
References: <20020430174511.A21356@zeus.centre-cired.fr>
	<shsk7qoqd4f.fsf@charged.uio.no>
	<20020502184121.B22985@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 173Xi6-0004HK-00
	for <nfs@lists.sourceforge.net>; Fri, 03 May 2002 00:42:34 -0700
To: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
In-Reply-To: <20020502184121.B22985@zeus.centre-cired.fr>
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

     > In case of an asynchronous call, is there such a difference
     > between 'soft' and 'hard' rpc calls too ?

Yes. 'hard' RPC calls will retry forever, and soft calls, will set
task->tk_status to EIO on a major timeout. This goes for both
synchronous and asynchronous calls.

     > I haven't seen anywhere what was the kind of rpc call of the
     > server side lockd.  Is it hard by default ?

You need to set the flag clnt->cl_soft in order to enable 'soft' RPC
calls. As you can see from the code, rpc.statd does this. The NLM
client code does so if and only if the NFS mount was soft. The lockd
server does not...

Note: for those RPC calls that don't expect the server to acknowledge
the call and return a value (e.g. NLM_*_MSG, NLM_*_RES) the 'hard'
call unfortunately does not offer any extra guarantees that the server
will *receive* the message. All it guarantees is that the message will
eventually get put on the wire...

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
