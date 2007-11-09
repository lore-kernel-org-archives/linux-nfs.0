From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] [PATCH 3/7] SUNRPC: Allow the client to detect if
	the TCP connection	is closed
Date: Fri, 09 Nov 2007 12:52:30 -0500
Message-ID: <EXNANE01IDT8zAJ95sZ00000909@exnane01.hq.netapp.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
	<EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
	<1194619730.7459.48.camel@heimdal.trondhjem.org>
	<EXNANE01CIFoPkG0rm300000904@exnane01.hq.netapp.com>
	<1194622369.7459.52.camel@heimdal.trondhjem.org>
	<EXNANE01rxUn3AkTR6000000905@exnane01.hq.netapp.com>
	<1194629839.7459.61.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Chuck Lever <Chuck.Lever@oracle.com>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1194629839.7459.61.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
	<EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
	<1194619730.7459.48.camel@heimdal.trondhjem.org>
	<EXNANE01CIFoPkG0rm300000904@exnane01.hq.netapp.com>
	<1194622369.7459.52.camel@heimdal.trondhjem.org>
	<EXNANE01rxUn3AkTR6000000905@exnane01.hq.netapp.com>
	<1194629839.7459.61.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

At 12:37 PM 11/9/2007, Trond Myklebust wrote:
>> Correct. And even if were sent, the FINWAIT1 state does not mean the
>> peer has transitioned. You need to see the ACK (which often comes in
>> the same packet as the peer's FIN).
>
>That is really of no direct concern to the RPC client. The important
>thing for us is to clear the XPRT_CONNECTED flag in order to indicate
>that the socket will no longer accept further requests, and we want to
>set XPRT_CLOSING in order to tell anybody who tries to reconnect that
>they need to wait.

Well, my concern is that the XPRT_CLOSING bit set may be delayed due to
network issues. What happens if a second task discovers the client while
it's pending? That's all.

>>  All this is a gawd-awful layering violation, you know. :-)
>
>I disagree. This is exactly the same thing as using poll() to monitor
>the state of the socket in userland.

But but but... poll() can't detect FIN_WAIT_1. It can only detect EOF,
i.e. CLOSE. I don't think this code could be implemented in userspace.

Here's my bottom line - if the RPC client is provably more correct with
this detail of the TCP state, then it's fine. I do think however that it's
unnecessary, i.e. the code can work without this, and simply set the
bits when the shutdown() is initiated.

Tom.
