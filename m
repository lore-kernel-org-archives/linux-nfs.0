From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] [PATCH 3/7] SUNRPC: Allow the client to detect if
	the TCP connection	is closed
Date: Fri, 09 Nov 2007 09:35:01 -0500
Message-ID: <EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Chuck Lever <Chuck.Lever@oracle.com>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1194618806.7459.44.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
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

At 09:33 AM 11/9/2007, Trond Myklebust wrote:
>> > 		break;
>> >-	case TCP_SYN_SENT:
>> >-	case TCP_SYN_RECV:
>> 
>> Why are you removing these states from the switch?
>
>There is no need for any special handling for these states, so just fall
>through.

Ah - the next line was "break;". Ack.

>
>> >+	case TCP_FIN_WAIT1:
>> >+		/* The client initiated a shutdown of the socket */
>> 
>> If the client initiated this, why does the bit management need to wait
>> for TCP to change state? I think what this means is that the client
>> initiated a FIN, *and* the server has acked it. Both these bits could
>> have been set when the FIN was sent, basically. Or is there some
>> subtlety here, in which case the comment should say more.
>
>No. TCP_FIN_WAIT1 is the standard name in TCP parlance for the state
>where the client has sent a FIN to the server, and is waiting for an ACK
>and/or a FIN in reply. See one of Stevens' famous TCP state diagrams.
>
>The TCP layer is therefore notifying us of this state change via the
>socket's sk->sk_state_change() callback. All we're doing in response is
>therefore to set the flags in the struct xprt to indicate that we have
>initiated a shutdown of the socket.

Oh - so in that case what you're actually doing is waiting for any data
to be sent, *and* then the FIN to be sent. Of course, the server hasn't
necessarily seen either yet.

I guess I return to my question - why not just set the XPRT bits when
we decided to close? Why wait for TCP to click through to this state?
It doesn't guarantee anything on the server until we see an ACK.

Tom.

>
>> >+		set_bit(XPRT_CLOSING, &xprt->state);
>> >+		smp_mb__before_clear_bit();
>> >+		clear_bit(XPRT_CONNECTED, &xprt->state);
>> >+		smp_mb__after_clear_bit();
>> > 		break;
