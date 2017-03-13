Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54116 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753777AbdCMQBu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Mar 2017 12:01:50 -0400
Date: Mon, 13 Mar 2017 12:01:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd: delegation conflicts between NFSv3 and NFSv4 accessors
Message-ID: <20170313160145.GD11746@parsley.fieldses.org>
References: <F2A98574-693E-4F72-B7D1-5FCEA851BC7C@oracle.com>
 <1489252126.3367.4.camel@redhat.com>
 <FFE72BE2-6CD5-434D-8DC0-6A5D393BEF4C@oracle.com>
 <1489266274.3367.6.camel@redhat.com>
 <20170313132749.GA11746@parsley.fieldses.org>
 <41257C5D-BFEF-4538-99A3-BBAA4EE99EE3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <41257C5D-BFEF-4538-99A3-BBAA4EE99EE3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 13, 2017 at 11:30:21AM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> 
> > On Mar 13, 2017, at 9:27 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > On Sat, Mar 11, 2017 at 04:04:34PM -0500, Jeff Layton wrote:
> >> On Sat, 2017-03-11 at 15:46 -0500, Chuck Lever wrote:
> >>>> On Mar 11, 2017, at 12:08 PM, Jeff Layton <jlayton@redhat.com> wrote:
> >>>> 
> >>>> On Sat, 2017-03-11 at 11:53 -0500, Chuck Lever wrote:
> >>>>> Hi Bruce, Jeff-
> >>>>> 
> >>>>> I've observed some interesting Linux NFS server behavior (v4.1.12).
> >>>>> 
> >>>>> We have a single system that has an NFSv4 mount via the kernel NFS
> >>>>> client, and an NFSv3 mount of the same export via a user space NFS
> >>>>> client. These two clients are accessing the same set of files.
> >>>>> 
> >>>>> The following pattern is seen on the wire. I've filtered a recent
> >>>>> capture on the FH of one of the shared files.
> >>>>> 
> >>>>> ---- cut here ----
> >>>>> 
> >>>>> 18507  19.483085    10.0.2.11 -> 10.0.1.8     NFS 238 V4 Call ACCESS FH: 0xc930444f, [Check: RD MD XT XE]
> >>>>> 18508  19.483827     10.0.1.8 -> 10.0.2.11    NFS 194 V4 Reply (Call In 18507) ACCESS, [Access Denied: XE], [Allowed: RD MD XT]
> >>>>> 18510  19.484676     10.0.1.8 -> 10.0.2.11    NFS 434 V4 Reply (Call In 18509) OPEN StateID: 0x6de3
> >>>>> 
> >>>>> This OPEN reply offers a read delegation to the kernel NFS client.
> >>>>> 
> >>>>> 18511  19.484806    10.0.2.11 -> 10.0.1.8     NFS 230 V4 Call GETATTR FH: 0xc930444f
> >>>>> 18512  19.485549     10.0.1.8 -> 10.0.2.11    NFS 274 V4 Reply (Call In 18511) GETATTR
> >>>>> 18513  19.485611    10.0.2.11 -> 10.0.1.8     NFS 230 V4 Call GETATTR FH: 0xc930444f
> >>>>> 18514  19.486375     10.0.1.8 -> 10.0.2.11    NFS 186 V4 Reply (Call In 18513) GETATTR
> >>>>> 18515  19.486464    10.0.2.11 -> 10.0.1.8     NFS 254 V4 Call CLOSE StateID: 0x6de3
> >>>>> 18516  19.487201     10.0.1.8 -> 10.0.2.11    NFS 202 V4 Reply (Call In 18515) CLOSE
> >>>>> 18556  19.498617    10.0.2.11 -> 10.0.1.8     NFS 210 V3 READ Call, FH: 0xc930444f Offset: 8192 Len: 8192
> >>>>> 
> >>>>> This READ call by the user space client does not conflict with the
> >>>>> read delegation.
> >>>>> 
> >>>>> 18559  19.499396     10.0.1.8 -> 10.0.2.11    NFS 8390 V3 READ Reply (Call In 18556) Len: 8192
> >>>>> 18726  19.568975     10.0.1.8 -> 10.0.2.11    NFS 310 V3 LOOKUP Reply (Call In 18725), FH: 0xc930444f
> >>>>> 18727  19.569170    10.0.2.11 -> 10.0.1.8     NFS 210 V3 READ Call, FH: 0xc930444f Offset: 0 Len: 512
> >>>>> 18728  19.569923     10.0.1.8 -> 10.0.2.11    NFS 710 V3 READ Reply (Call In 18727) Len: 512
> >>>>> 18729  19.570135    10.0.2.11 -> 10.0.1.8     NFS 234 V3 SETATTR Call, FH: 0xc930444f
> >>>>> 18730  19.570901     10.0.1.8 -> 10.0.2.11    NFS 214 V3 SETATTR Reply (Call In 18729) Error: NFS3ERR_JUKEBOX
> >>>>> 
> >>>>> The user space client has attempted to extend the file. This does
> >>>>> conflict with the read delegation held by the kernel NFS client,
> >>>>> so the server returns JUKEBOX, the equivalent of NFS4ERR_DELAY.
> >>>>> This causes a negative performance impact on the user space NFS
> >>>>> client.
> >>>>> 
> >>>>> 18731  19.575396    10.0.2.11 -> 10.0.1.8     NFS 250 V4 Call DELEGRETURN StateID: 0x6de3
> >>>>> 18732  19.576132     10.0.1.8 -> 10.0.2.11    NFS 186 V4 Reply (Call In 18731) DELEGRETURN
> >>>>> 
> >>>>> No CB_RECALL was done to trigger this DELEGRETURN. Apparently
> >>>>> the application that was accessing this file via the kernel OS
> >>>>> client decided already that it no longer needed the file before
> >>>>> the server could send the CB_RECALL. Sign of perhaps a race
> >>>>> between the applications accessing the file via these two
> >>>>> mounts.
> >>>>> 
> >>>>> ---- cut here ----
> >>>>> 
> >>>>> The server is aware of non-NFSv4 accessors of this file in frame
> >>>>> 18556. NFSv3 has no OPEN operation, of course, so it's not
> >>>>> possible for the server to determine how the NFSv3 client will
> >>>>> subsequently access this file.
> >>>>> 
> >>>> 
> >>>> Right. Why should we assume that the v3 client will do anything other
> >>>> than read there? If we recall the delegation just for reads, then we
> >>>> potentially negatively affect the performance of the v4 client.
> >>>> 
> >>>>> Seems like at frame 18556, it would be a best practice to recall
> >>>>> the delegation to avoid potential future conflicts, such as the
> >>>>> SETATTR in frame 18729.
> >>>>> 
> >>>>> Or, perhaps that READ isn't the first NFSv3 access of that file.
> >>>>> After all, a LOOKUP would have to be done to retrieve that file's
> >>>>> FH. The OPEN in frame 18556 perhaps could have avoided offering
> >>>>> the READ delegation, knowing there is a recent non-NFSv4 accessor
> >>>>> of that file.
> >>>>> 
> >>>>> Would these be difficult or inappropriate policies to implement?
> >>>>> 
> >>>>> 
> >>>> 
> >>>> Reads are not currently considered to be conflicting access vs. a read
> >>>> delegation.
> >>> 
> >>> Strictly speaking, a single NFSv3 READ does not violate the guarantee
> >>> made by the read delegation. And, strictly speaking, there can be no
> >>> OPEN conflict because NFSv3 does not have an OPEN operation.
> >>> 
> >>> The question is whether the server has an adequate mechanism for
> >>> delaying NFSv3 accessors when an NFSv4 delegation must be recalled.
> >>> 
> >>> NFS3ERR_JUKEBOX and NFS4ERR_DELAY share the same numeric value, but
> >>> imply different semantics.
> >>> 
> >>> RFC1813 says:
> >>> 
> >>> NFS3ERR_JUKEBOX
> >>>    The server initiated the request, but was not able to
> >>>    complete it in a timely fashion. The client should wait
> >>>    and then try the request with a new RPC transaction ID.
> >>>    For example, this error should be returned from a server
> >>>    that supports hierarchical storage and receives a request
> >>>    to process a file that has been migrated. In this case,
> >>>    the server should start the immigration process and
> >>>    respond to client with this error.
> >>> 
> >>> Some clients respond to NFS3ERR_JUKEBOX by waiting quite some time
> >>> before retrying.
> >>> 
> >>> RFC7530 says:
> >>> 
> >>> 13.1.1.3.  NFS4ERR_DELAY (Error Code 10008)
> >>> 
> >>>   For any of a number of reasons, the replier could not process this
> >>>   operation in what was deemed a reasonable time.  The client should
> >>>   wait and then try the request with a new RPC transaction ID.
> >>> 
> >>>   The following are two examples of what might lead to this situation:
> >>> 
> >>>   o  A server that supports hierarchical storage receives a request to
> >>>      process a file that had been migrated.
> >>> 
> >>>   o  An operation requires a delegation recall to proceed, and waiting
> >>>      for this delegation recall makes processing this request in a
> >>>      timely fashion impossible.
> >>> 
> >>> An NFSv4 client is prepared to retry this error almost immediately
> >>> because most of the time it is due to the second bullet.
> >>> 
> >>> I agree that not recalling after an NFSv3 READ is reasonable in some
> >>> cases. However, I demonstrated a case where the current policy does
> >>> not serve one of these clients well at all. In fact, the NFSv3
> >>> accessor in this case is the performance-sensitive one.
> >>> 
> >>> To put it another way, the NFSv4 protocol does not forbid the
> >>> current Linux server policy, but interoperating well with existing
> >>> NFSv3 clients suggests it's not an optimal policy choice.
> >>> 
> >> 
> >> I think that is entirely dependent on the workload. If we proactively
> >> recall delegations because we think the v3 client _might_ do some
> >> conflicting access, and then it doesn't, then that's also a non-optimal
> >> choice.
> >> 
> >>> 
> >>>> I think that's the correct thing to do. Until we have some
> >>>> sort of conflicting behavior I don't see why you'd want to prematurely
> >>>> recall the delegation.
> >>> 
> >>> The reason to recall a delegation is to avoid returning
> >>> NFS3ERR_JUKEBOX if at all possible, because doing so is a drastic
> >>> remedy that results in a performance regression.
> >>> 
> >>> The negative impact of not having a delegation is small. The negative
> >>> impact of returning NFS3ERR_JUKEBOX to a SETATTR or WRITE can be as
> >>> much as a 5 minute wait. (This is intolerably long for, say, online
> >>> transaction processing workloads).
> >>> 
> >> 
> >> That sounds like a deficient v3 client, IMO. There's nothing in the v3
> >> spec that I know of that advocates a delay that long before
> >> reattempting. I'm pretty sure the Linux client treats NFSERR3_JUKEBOX
> >> and NFS4ERR_DELAY more or less equivalently.
> > 
> > The v3 client uses a 5 second delay (see NFS_JUKEBOX_RETRY_TIME).
> 
> > The v4 client, at least in the case of operations that could break a
> > deleg, does exponential backoff starting with a tenth of a second--see
> > nfs4_delay.
> > 
> > So Trond's been taking the spec at its word here.
> > 
> > Like Jeff I'm pretty unhappy at the idea of revoking delegations
> > preemptively on v3 read and lookup.
> 
> To completely avoid JUKEBOX, you'd have to recall asynchronously.
> Even better would be not to offer delegations when it is clear
> there is an active NFSv3 accessor.
> 
> Is there a specific use case where holding onto delegations in
> this case is measurably valuable?
> 
> As Jeff said above, it is workload dependent, but it seems that
> we are choosing arbitrarily which workloads work well and which
> will be penalized.
> 
> Clearly, speculating about future access is not allowed when
> only NFSv4 is in play.
> 
> 
> > And a 5 minute wait does sound like a client problem.
> 
> Even a 5 second wait is not good. A simple "touch" that takes
> five seconds can generate user complaints.
> 
> I do see the point that a NFSv3 client implementation can be
> changed to retry JUKEBOX more aggressively. Not all NFSv3 code
> bases are actively maintained, however.
> 
> 
> >>> The server can detect there are other accessors that do not provide
> >>> OPEN/CLOSE semantics. In addition, the server cannot predict when one
> >>> of these accessors may use a WRITE or SETATTR. And finally it does
> >>> not have a reasonably performant mechanism for delaying those
> >>> accessors when a delegation must be recalled.
> >>> 
> >> 
> >> Interoperability is hard (and sometimes it doesn't work well :). We
> >> simply don't have enough info to reliably guess what the v3 client will
> >> do in this situation.
> 
> (This is in response to Jeff's comment)
> 
> Interoperability means following the spec, but IMO it also
> means respecting longstanding implementation practice when
> a specification does not prescribe particular behavior.
> 
> In this case, strictly speaking interoperability is not the
> concern.
> 
> -> The spec authors clearly believed this is an area where
> implementations are to be given free rein. Otherwise the text
> would have provided RFC 2119 directives or other specific
> guidelines. There was opportunity to add specifics in RFCs
> 3530, 7530, and 5661, but that wasn't done.
> 
> -> The scenario I reported does not involve operational
> failure. It eventually succeeds whether the client's retry
> is aggressive or lazy. It just works _better_ when there is
> no DELAY/JUKEBOX.
> 
> There are a few normative constraints here, and I think we
> have a bead on what those are, but IMO the issue is one of
> implementation quality (on both ends).
> 
> /soapbox
> 
> 
> >> That said, I wouldn't have a huge objection to a server side tunable
> >> (module parameter?) that says "Recall read delegations on v2/3 READ
> >> calls". Make it default to off, and then people in your situation could
> >> set it if they thought it a better policy for their workload.
> 
> > I also wonder if in v3 case we should try a small synchronous wait
> > before returning JUKEBOX.  Read delegations shouldn't require the client
> > to do very much, so it could be they're typically returned in a
> > fraction of a second.
> 
> That wait would have to be very short in the NFSv3 / UDP case
> to avoid a retransmit timeout. I know, UDP is going away.
> 
> It's hard to say how long to wait. The RTT to the client might
> have to be taken into account. In WAN deployments, this could
> be as long as 50ms, for instance.
> 
> Although, again, waiting is speculative. A fixed 20ms wait
> would be appropriate for most LAN deployments, and that's
> where the expectation of consistently fast operation lies.

That wait doesn't sound bad at all.

The server could track round trip times to the clients holding
delegations and use that to estimate the right wait time, but hopefully
that's overkill.

I think the occasional retransmitted truncate probably isn't a big deal.
Seems like the kind of thing the reply cache would handle well.

> > Since we have a fixed number of threads, I don't think we'd want to keep
> > one waiting much longer than that.  Also, it'd be nice if we could get
> > woken up early when the delegation return comes in before our wait's
> > over, but I haven't thought about how to do that.
> > 
> > And I don't know if that actually helps.
> 
> When there is a lot of file sharing between clients, it might
> be good to reduce the penalty of delegation recalls.
> 
> Clients, after all, cannot know when a recall has completed,
> so they have to guess about when to retransmit, and usually
> make a conservative estimate. If server behavior can shorten
> the delay without introducing race windows, that would be good
> added value.
> 
> But I'm not clear why waiting must tie up the nfsd thread (pun
> intended). How is a COMMIT or synchronous WRITE handled? Seems
> like waiting for a delegation recall to complete is a similar
> kind of thing.

I agree, if the wait time is on the order of the time you'd spend
waiting for disk, then it's quite reasonable.

There is one odd issue, which maybe wouldn't be an issue in practice,
but: to release the delegation, we need a thread free to process the
delegation return.  So there's a deadlock if we allow threads to wait
for delegation returns.  The timeout should prevent the deadlock.  But
if there was some event that caused a bunch of near-simultaneous
delegation-recalling NFSv3 operations, then in theory waiting could make
the problem worse by delaying the handling of the delegation return.

But I think it's not a big risk, and we could manage it somehow if I
turned out to be wrong....

--b.
