From: Dumas Patrice <dumas@centre-cired.fr>
Subject: Re: patchs for lockd: granted_res_proc, client address check, blocking check
Date: Fri, 26 Apr 2002 13:53:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020426135330.B30251@zeus.centre-cired.fr>
References: <20020423103152.A3624@zeus.centre-cired.fr> <20020425155951.E13292@zeus.centre-cired.fr> <shsznzqzt0q.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1714NI-0004JE-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Apr 2002 04:58:52 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id NAA05943
          for <nfs@lists.sourceforge.net>; Fri, 26 Apr 2002 13:57:08 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3QBrUJ30335
	for nfs@lists.sourceforge.net; Fri, 26 Apr 2002 13:53:30 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shsznzqzt0q.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Fri, Apr 26, 2002 at 11:52:21AM +0200
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

Hi,

> Just add a call to posix_test_lock() in nlmclnt_grant().

Ok.

> The client occasionally wakes up and resends the NLM_LOCK call, so it
> will not wait for ever. However what say the server misses the
> client's GRANTED_RES reply?

In that case the server resend (after 60 * HZ which seems to be one minute) a
GRANTED_MSG.
 
> The above problems are exactly why we should aim to use NLM_GRANTED
> instead of NLM_GRANTED_MSG at some point in the future.

I don't think it would solve that problem. The client could also never reply 
to the GRANTED call, and we are back with the same problem. The client rpc 
reply to GRANTED and the client rpc call to GRANTED_RES play exactly the same 
role, and leads to the same problem when they are lost (and should lead to the 
same behaviour at the server side, in my opinion, maybe with different timers). 

To clarify things, as they are, and what I propose, I submit some possible
behaviours for GRANTED_MSG implementation and the for GRANTED implementations.
I suppose that the rpc call are async in both cases. There is a note at the end
for sync calls.

resend means: retry a call
couldn't send means: rpc async call timed out
unlock means: unlock the lock and forget the block

GRANTED_MSG calls:

1. actual code
   * The server couldn't send the GRANTED_MSG: resend after 10 s
   * The server send succesfully: resend after 60 s
2. lazy server
   * The server couldn't send the GRANTED_MSG: unlock
   * The server send succesfully: unlock
3. my proposal: each time the server resends, it increases a counter
   * The server couldn't send the GRANTED_MSG : resend after 10 s
   * The server send succesfully: resend after 60 s
   * the counter exceeded a limit: unlock

The GRANTED equivalents are:
1.
   * The server couldn't send the GRANTED: resend after 60 s
2.
   * The server couldn't send the GRANTED: unlock
3. each time the server resends, it increases a counter
   * The server couldn't send the GRANTED: resend after 60 s
   * the counter exceeded a limit: unlock

Solution 1 may lead to server retaining a lock.
Solution 2 and 3 may lead to client thinking it has a lock or blocking
depending whether or not he allready send GRANTED_RES/GRANTED reply or not. The
blocking case cannot happen with current linux lockd client implementation.

Using rpc sync call is the same as 1 if there is no timeout, and the same as 2
if there is one. According to a comment in the code there may be other
problems:

 *  -   we don't want to use a synchronous RPC thread, otherwise
 *      we might find ourselves hanging on a dead portmapper.




Nevertheless, I am working on a GRANTED call implementation, but more for
standard conformance and completeness than to resolve that issue. My proposal
here is 

If the initial call is LOCK, try a GRANTED call, and it it times out, revert to
GRANTED_MSG (needed because:
 *  -   Some lockd implementations (e.g. HP) don't react to
 *      RPC_GRANTED calls; they seem to insist on RPC_GRANTED_MSG calls.
)

If the initial call is LOCK_MSG, no change.

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
