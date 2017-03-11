Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44039 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdCKUrA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Mar 2017 15:47:00 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: nfsd: delegation conflicts between NFSv3 and NFSv4 accessors
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1489252126.3367.4.camel@redhat.com>
Date: Sat, 11 Mar 2017 15:46:54 -0500
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FFE72BE2-6CD5-434D-8DC0-6A5D393BEF4C@oracle.com>
References: <F2A98574-693E-4F72-B7D1-5FCEA851BC7C@oracle.com> <1489252126.3367.4.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 11, 2017, at 12:08 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> On Sat, 2017-03-11 at 11:53 -0500, Chuck Lever wrote:
>> Hi Bruce, Jeff-
>> 
>> I've observed some interesting Linux NFS server behavior (v4.1.12).
>> 
>> We have a single system that has an NFSv4 mount via the kernel NFS
>> client, and an NFSv3 mount of the same export via a user space NFS
>> client. These two clients are accessing the same set of files.
>> 
>> The following pattern is seen on the wire. I've filtered a recent
>> capture on the FH of one of the shared files.
>> 
>> ---- cut here ----
>> 
>> 18507  19.483085    10.0.2.11 -> 10.0.1.8     NFS 238 V4 Call ACCESS FH: 0xc930444f, [Check: RD MD XT XE]
>> 18508  19.483827     10.0.1.8 -> 10.0.2.11    NFS 194 V4 Reply (Call In 18507) ACCESS, [Access Denied: XE], [Allowed: RD MD XT]
>> 18510  19.484676     10.0.1.8 -> 10.0.2.11    NFS 434 V4 Reply (Call In 18509) OPEN StateID: 0x6de3
>> 
>> This OPEN reply offers a read delegation to the kernel NFS client.
>> 
>> 18511  19.484806    10.0.2.11 -> 10.0.1.8     NFS 230 V4 Call GETATTR FH: 0xc930444f
>> 18512  19.485549     10.0.1.8 -> 10.0.2.11    NFS 274 V4 Reply (Call In 18511) GETATTR
>> 18513  19.485611    10.0.2.11 -> 10.0.1.8     NFS 230 V4 Call GETATTR FH: 0xc930444f
>> 18514  19.486375     10.0.1.8 -> 10.0.2.11    NFS 186 V4 Reply (Call In 18513) GETATTR
>> 18515  19.486464    10.0.2.11 -> 10.0.1.8     NFS 254 V4 Call CLOSE StateID: 0x6de3
>> 18516  19.487201     10.0.1.8 -> 10.0.2.11    NFS 202 V4 Reply (Call In 18515) CLOSE
>> 18556  19.498617    10.0.2.11 -> 10.0.1.8     NFS 210 V3 READ Call, FH: 0xc930444f Offset: 8192 Len: 8192
>> 
>> This READ call by the user space client does not conflict with the
>> read delegation.
>> 
>> 18559  19.499396     10.0.1.8 -> 10.0.2.11    NFS 8390 V3 READ Reply (Call In 18556) Len: 8192
>> 18726  19.568975     10.0.1.8 -> 10.0.2.11    NFS 310 V3 LOOKUP Reply (Call In 18725), FH: 0xc930444f
>> 18727  19.569170    10.0.2.11 -> 10.0.1.8     NFS 210 V3 READ Call, FH: 0xc930444f Offset: 0 Len: 512
>> 18728  19.569923     10.0.1.8 -> 10.0.2.11    NFS 710 V3 READ Reply (Call In 18727) Len: 512
>> 18729  19.570135    10.0.2.11 -> 10.0.1.8     NFS 234 V3 SETATTR Call, FH: 0xc930444f
>> 18730  19.570901     10.0.1.8 -> 10.0.2.11    NFS 214 V3 SETATTR Reply (Call In 18729) Error: NFS3ERR_JUKEBOX
>> 
>> The user space client has attempted to extend the file. This does
>> conflict with the read delegation held by the kernel NFS client,
>> so the server returns JUKEBOX, the equivalent of NFS4ERR_DELAY.
>> This causes a negative performance impact on the user space NFS
>> client.
>> 
>> 18731  19.575396    10.0.2.11 -> 10.0.1.8     NFS 250 V4 Call DELEGRETURN StateID: 0x6de3
>> 18732  19.576132     10.0.1.8 -> 10.0.2.11    NFS 186 V4 Reply (Call In 18731) DELEGRETURN
>> 
>> No CB_RECALL was done to trigger this DELEGRETURN. Apparently
>> the application that was accessing this file via the kernel OS
>> client decided already that it no longer needed the file before
>> the server could send the CB_RECALL. Sign of perhaps a race
>> between the applications accessing the file via these two
>> mounts.
>> 
>> ---- cut here ----
>> 
>> The server is aware of non-NFSv4 accessors of this file in frame
>> 18556. NFSv3 has no OPEN operation, of course, so it's not
>> possible for the server to determine how the NFSv3 client will
>> subsequently access this file.
>> 
> 
> Right. Why should we assume that the v3 client will do anything other
> than read there? If we recall the delegation just for reads, then we
> potentially negatively affect the performance of the v4 client.
> 
>> Seems like at frame 18556, it would be a best practice to recall
>> the delegation to avoid potential future conflicts, such as the
>> SETATTR in frame 18729.
>> 
>> Or, perhaps that READ isn't the first NFSv3 access of that file.
>> After all, a LOOKUP would have to be done to retrieve that file's
>> FH. The OPEN in frame 18556 perhaps could have avoided offering
>> the READ delegation, knowing there is a recent non-NFSv4 accessor
>> of that file.
>> 
>> Would these be difficult or inappropriate policies to implement?
>> 
>> 
> 
> Reads are not currently considered to be conflicting access vs. a read
> delegation.

Strictly speaking, a single NFSv3 READ does not violate the guarantee
made by the read delegation. And, strictly speaking, there can be no
OPEN conflict because NFSv3 does not have an OPEN operation.

The question is whether the server has an adequate mechanism for
delaying NFSv3 accessors when an NFSv4 delegation must be recalled.

NFS3ERR_JUKEBOX and NFS4ERR_DELAY share the same numeric value, but
imply different semantics.

RFC1813 says:
 
NFS3ERR_JUKEBOX
    The server initiated the request, but was not able to
    complete it in a timely fashion. The client should wait
    and then try the request with a new RPC transaction ID.
    For example, this error should be returned from a server
    that supports hierarchical storage and receives a request
    to process a file that has been migrated. In this case,
    the server should start the immigration process and
    respond to client with this error.

Some clients respond to NFS3ERR_JUKEBOX by waiting quite some time
before retrying.

RFC7530 says:

13.1.1.3.  NFS4ERR_DELAY (Error Code 10008)

   For any of a number of reasons, the replier could not process this
   operation in what was deemed a reasonable time.  The client should
   wait and then try the request with a new RPC transaction ID.

   The following are two examples of what might lead to this situation:

   o  A server that supports hierarchical storage receives a request to
      process a file that had been migrated.

   o  An operation requires a delegation recall to proceed, and waiting
      for this delegation recall makes processing this request in a
      timely fashion impossible.

An NFSv4 client is prepared to retry this error almost immediately
because most of the time it is due to the second bullet.

I agree that not recalling after an NFSv3 READ is reasonable in some
cases. However, I demonstrated a case where the current policy does
not serve one of these clients well at all. In fact, the NFSv3
accessor in this case is the performance-sensitive one.

To put it another way, the NFSv4 protocol does not forbid the
current Linux server policy, but interoperating well with existing
NFSv3 clients suggests it's not an optimal policy choice.


> I think that's the correct thing to do. Until we have some
> sort of conflicting behavior I don't see why you'd want to prematurely
> recall the delegation.

The reason to recall a delegation is to avoid returning
NFS3ERR_JUKEBOX if at all possible, because doing so is a drastic
remedy that results in a performance regression.

The negative impact of not having a delegation is small. The negative
impact of returning NFS3ERR_JUKEBOX to a SETATTR or WRITE can be as
much as a 5 minute wait. (This is intolerably long for, say, online
transaction processing workloads).

The server can detect there are other accessors that do not provide
OPEN/CLOSE semantics. In addition, the server cannot predict when one
of these accessors may use a WRITE or SETATTR. And finally it does
not have a reasonably performant mechanism for delaying those
accessors when a delegation must be recalled.


> Note that we do have a bloom filter now that prevents us from handing
> out a delegation on a file that was recently recalled. Does that help at
> all here?

Not offering a delegation again will help during subsequent accesses,
though not for the initial write access.


--
Chuck Lever



