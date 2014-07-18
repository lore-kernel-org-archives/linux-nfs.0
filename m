Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:26656 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906AbaGRT1T convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 15:27:19 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] svcrdma: Select NFSv4.1 backchannel transport based on forward channel
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140718191256.GB12801@fieldses.org>
Date: Fri, 18 Jul 2014 15:27:10 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F69F9045-6ECC-4210-837C-2837AF37D7ED@oracle.com>
References: <20140716193542.7847.95868.stgit@klimt.1015granger.net> <20140717183621.GA30442@fieldses.org> <9D651FDC-7C11-476A-AE50-746E6E37B3E2@oracle.com> <99240537-8EC8-4ED3-8574-B95AC8A42F56@oracle.com> <20140718191256.GB12801@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 18, 2014, at 3:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Jul 18, 2014 at 02:47:41PM -0400, Chuck Lever wrote:
>> 
>> On Jul 17, 2014, at 2:59 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Jul 17, 2014, at 2:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>>> On Wed, Jul 16, 2014 at 03:38:32PM -0400, Chuck Lever wrote:
>>>>> The current code always selects XPRT_TRANSPORT_BC_TCP for the back
>>>>> channel, even when the forward channel was not TCP (eg, RDMA). When
>>>>> a 4.1 mount is attempted with RDMA, the server panics in the TCP BC
>>>>> code when trying to send CB_NULL.
>>>>> 
>>>>> Instead, construct the transport protocol number from the forward
>>>>> channel transport or'd with XPRT_TRANSPORT_BC. Transports that do
>>>>> not support bi-directional RPC will not have registered a "BC"
>>>>> transport, causing create_backchannel_client() to fail immediately.
>>>>> 
>>>>> Fixes: https://bugzilla.linux-nfs.org/show_bug.cgi?id=265
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>> Hi Bruce-
>>>>> 
>>>>> What do you think of this approach?
>>>> 
>>>> OK by me.  (So clients use a separate tcp connection for the
>>>> backchannel?)
>>> 
>>> Right.
>>> 
>>> The current plan is that, for NFSv4.1 over RDMA, the Linux client will
>>> create an additional TCP connection and bind it to the same session as
>>> the RDMA transport.
>>> 
>>> The TCP connection will be used solely for callback operations.  The
>>> forward channel on that connection will not be used, except for
>>> BIND_CONN_TO_SESSION operations.
>> 
>> Hi Bruce, pursuant to this goal, I’m trying to understand commit
>> 14a24e99, especially the interior comment:
>> 
>> 3114 /* Should we give out recallable state?: */
>> 3115 static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
>> 3116 {
>> 3117         if (clp->cl_cb_state == NFSD4_CB_UP)
>> 3118                 return true;
>> 3119         /*
>> 3120          * In the sessions case, since we don't have to establish a
>> 3121          * separate connection for callbacks, we assume it's OK
>> 3122          * until we hear otherwise:
>> 3123          */
>> 3124         return clp->cl_minorversion && clp->cl_cb_state == NFSD4_CB_UNKNOWN;
>> 3125 }
>> 
>> I wonder if that’s a valid assumption?
>> 
>> A separate virtual connection _does_ have to be established. If the
>> client sent a CREATE_SESSION operation with the SESSION4_BACK_CHAN flag
>> set, the server must verify that the client has an active bi-directional
>> RPC service on the transport.
> 
> If the client sets the BACK_CHAN flag, that means it wants that
> connection to be used as a back channel.
> 
> So in the RDMA case it sounds like the client needs to clear that flag
> on the create session.

Right.

> Either that or send the original CREATE_SESSION over the connection you
> want used for the backchannel, then send a BIND_CONNECTION_TO_SESSION
> over the RDMA connection.
> 
> That said, if the server knows there's no connection at all that's
> available for the backchannel, then yes I agree that it should be
> setting the PATH_DOWN flag:

I’m trying a fix that sets cl_cb_state = NFSD4_CB_DOWN in
init_session() if SESSION4_BACK_CHAN is clear.

>From the looks of it, the server is architected to support one and
only one session per client ID. Is that correct? Thus it expects
just one CREATE_SESSION operation per EXCHANGE_ID. Does the server
enforce this?

Seems like cl_cb_state really should be a per-session thing for
NFSv4.1.

And, while we’re at it, the server should assert
SEQ4_STATUS_CB_PATH_DOWN_SESSION as well as SEQ4_STATUS_CB_PATH_DOWN.

> 
>> Otherwise it can hand out recallable state
>> to a client with no callback service. Is that always safe?
>> 
>> Or, if the client sent a CREATE_SESSION operation with the
>> SESSION4_BACK_CHAN flag cleared, then either the client intends not to
>> set up a backchannel, or it intends to establish a separate transport
>> for the backchannel. There is no backchannel in that case until the
>> client establishes it.
>> 
>> Right now, if the client does not set SESSION4_BACK_CHAN, the server
>> never asserts SEQ4_STATUS_CB_PATH_DOWN, even though there is no
>> backchannel. That seems like a (minor, perhaps) bug.
> 
> Yes, agreed, I'll take a look--how are you reproducing?

Prototype Linux client that doesn’t set SESSION4_BACK_CHAN when it does
CREATE_SESSION. Preparing it for RDMA support.

You could code a pyNFS test.

> The
> nfsd4_probe_callback() should result in NFSD4_CB_DOWN getting set as
> soon as the workqueue process it.

Clearing SESSION4_BACK_CHAN squelches nfsd4_probe_callback(), so
the server never checks in this case.

> In theory there's a race there (I
> should fix that) in practice I'd normally expect that to run before we
> process a SEQUENCE request on the new session.

>> Do you remember what this commit was trying to fix?
> 
> It's not a bugfix, just a minor optimization.  We could revert it if
> need be.

NP, I just don’t see how it helps to make that assumption, plus it
doesn’t seem entirely safe.

My initial question was "why does alloc_client() initialize cl_cb_state
to NFSD4_CB_UNKNOWN instead of NFSD4_CB_DOWN?”

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



