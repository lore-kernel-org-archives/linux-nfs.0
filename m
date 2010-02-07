Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:22208 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab0BGAxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Feb 2010 19:53:43 -0500
Message-ID: <4B6E0EF5.70307@oracle.com>
Date: Sat, 06 Feb 2010 19:53:09 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
CC: linux-nfs@vger.kernel.org, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind, restablish
 so that they sensitive to the major time out value
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com> <1265155576-7618-2-git-send-email-batsakis@netapp.com> <1265155576-7618-3-git-send-email-batsakis@netapp.com> <1265155576-7618-4-git-send-email-batsakis@netapp.com> <1265155576-7618-5-git-send-email-batsakis@netapp.com> <1265155576-7618-6-git-send-email-batsakis@netapp.com> <1265155576-7618-7-git-send-email-batsakis@netapp.com> <4B6C7BCA.2040806@oracle.com> <383F4881-BD88-4155-B605-4D24F5B05BDD@netapp.com> <4B6C9FA7.2010702@oracle.com> <77EBFB14-A6B6-41DC-90DC-7A00548DFAEA@netapp.com> <4B6CB3C7.8070001@oracle.com> <B9364369CA66BF45806C2CD86EAB8BA60259D23D@SACMVEXC3-PRD.hq.netapp.com>
In-Reply-To: <B9364369CA66BF45806C2CD86EAB8BA60259D23D@SACMVEXC3-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/05/2010 11:05 PM, Batsakis, Alexandros wrote:
>
> My replies marked with the "AB" prefix
>
> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Fri 2/5/2010 4:11 PM
> To: Batsakis, Alexandros
> Cc: Batsakis, Alexandros; linux-nfs@vger.kernel.org; Myklebust, Trond
> Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind,
> restablish so that they sensitive to the major time out value
>
> On 02/05/2010 06:04 PM, Batsakis, Alexandros wrote:
>  >
>  >
>  > On Feb 5, 2010, at 14:47, "Chuck Lever" <chuck.lever@oracle.com> wrote:
>  >
>  >> On 02/05/2010 05:14 PM, Batsakis, Alexandros wrote:
>  >>> Yeah sure,
>  >>>
>  >>> So imagine that for a specific connection the remaining major timeo
>  >>> value is 30secs. Xs_connect has a default timeout before attempting to
>  >>> reconnect of 60secs. The user (NFS) expects to "hear back" from the rpc
>  >>> layer within the timeout as in often cases e.g. lease renewal, it's of
>  >>> no benefit for an operation to reach the server at a later time and
> miss
>  >>> the critical time because it was sleeping for an arbitrary amount of
>  >>> time.
>
> Maybe you want RPC_TASK_SOFTCONN for NFSv4 renewals instead of
> RPC_TASK_SOFT. This would cause the RENEW request to fail immediately
> if the transport can't connect.
>
> AB: is this a new flag ? I am not familiar with it. Or are you proposing
> to add such a flag?
> It's not an unreasonable thing to do

The flag was added recently (maybe in 2.6.33-rc?).  It causes an 
individual RPC request to fail immediately if the underlying transport 
cannot be connected.  It bypasses the reconnect timeout if the transport 
is not already connected.

> Can you describe the scenario more precisely? If I wanted to reproduce
> this here, how would I do it?
>
> AB: mount a 4.1 server (or v4 with state, e.g. an open/lock etc.)
> Then kill the server. With a lease time of 90 seconds the client
> attempts to reconnect will come
> roughly at 60-80secs and 120-140 secs. So the lease period of 90 secs is
> lost.

That doesn't sound right to me.  xs_connect is supposed to retry after 3 
seconds and then back off exponentially until it is retrying once every 
5 minutes.  How do you determine when the client is retrying the 
connect: by watching for SYN packets or by enabling dprintk messages in 
xprtsock?

>  >> There are good reasons why there is a timeout before reestablishing a
>  >> connection. Have you tested this patch with NFSv3 servers that are
>  >> going up and down repeatedly, for example? I think skipping the
>  >> reconnect delay could have consequences for the cases which the
>  >> original xs_connect logic is supposed to address, and it's not
>  >> something we want in many other cases.
>  >>
>  >
>  > I am not skipping the reconnect delay. What i am saying is that it seems
>  > wrong to me to hard-code the reconnection delay. Why 60secs for example
>  > ? To me it seems that this value should be related to the timeout. Do
>  > you disagree ?
>
> Hrm. It looks like the TCP re-establish timeout starts at 3 seconds,
> and then backs off to 5 minutes. So, it's not fixed, it's related to
> how quickly the server responds to the client's connect() attempt.
>
> AB: Agreed. All I am saying is let's cap this value.

It's capped today at 5 minutes.  See XS_TCP_MAX_REEST_TO.  Perhaps it 
could be lowered to 60 seconds.

But I don't yet see a need to link the reconnect timeout to the 
retransmit timeout.  In nearly every case, a major timeout should occur 
if the client can't reconnect, and there's no harm done if that's 
delayed longer than is optimal.

RENEW is really quite the exception here.  This procedure is the only 
one I can think of where the request has to start _and_ finish within a 
particular time limit.

I don't know as much about NFSv4 and especially RENEW as I should, but 
it seems to me there are a number of reasons why RENEW should perhaps be 
given its own transport.

1.  If a RENEW is sent every 90 seconds, that means there's no 
possibility for the underlying transports to idle out.

2.  We only need one RENEW per client-server pair, I think.  Isn't it 
tied to the client ID?

3.  Because of its timing requirements, we can't depend on a RENEW 
getting through a heavily loaded rpc_clnt at a given time.

4.  It seems to want different retransmit behavior than any other procedure.

So perhaps the best solution is for the client to set up a separate 
rpc_clnt/rpc_xprt for each mounted server (but not each mount point) 
that is dedicated to handling RENEW requests for that server.  It would 
have retransmit timeouts that are determined by the lease timer, and not 
by the retransmit timeout specified on the mount command line.

This works around the fact that TCP streams suffer from head-of-queue 
blocking, as well as attempting to work around a long RPC client backlog 
queue.

The only downside I can think of is this might consume excess privileged 
ports on a client that mounts hundreds of different servers.

>  >> Perhaps a better idea would be to mark these particular RPCs with some
>  >> kind of indication that the RPC client has to connect immediately for
>  >> this request, if possible. Similar to RPC_TASK_SOFTCONN.
>  >
>  >> In general, sunrpc.ko has a problem with this kind of "urgent" RPC
>  >> request. If the RPC backlog queue is large for a particular rpc_clnt,
>  >> it can often take many seconds (like longer than the major timeout)
>  >> for a request to actually get down to the transport and get sent. I
>  >> don't see that these timeout changes necessarily address that at all.
>
> AB: again here I think that the correct solution would be to increase
> the timeout value rather than ignore it. What is the purpose of the
> timeout anyways then ?
>
>  > Bu if the timeout has expired rpc_execute will quit the task anyways.
>  > What is the downside of instead of sleeping for a long, arbitrary period
>  > to wake up and poll the server at intervals that actually make some
>  > sense to the client?
>
> If the 5 minute backoff maximum is too long, then you can easily reduce
> that maximum (which is probably not unreasonable). We originally had
> the client retrying to connect every 3 seconds, but it was thought that
> would put unnecessary load on servers.
>
> AB: Again, my argument is that we shouldn't select these values arbitrarily.
> In all, I see your points. If I understand correctly
> you don't consider the tcp reconnection policy that I am describing an
> important issue. I assume that you are OK
> with the timeout variability in the state machine ?

I think changing the timeout logic in both places is probably overkill, 
and may even have negative effects on nonidempotent requests.  I think 
it's wise to depend on retransmit settings as little as possible, as 
retransmitting an RPC is basically a hack, when you get right down to it.

I'm still open to discussion, though.

-- 
chuck[dot]lever[at]oracle[dot]com
