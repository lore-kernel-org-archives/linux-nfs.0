Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1503190633310.947@planck.local>
References: <alpine.OSX.2.19.9992.1503190633310.947@planck.local>
Date: Sun, 22 Mar 2015 15:20:05 -0400
Message-ID: <CAHQdGtSRUdNmx8dhDJ0gPbBuukX4ggUQJ638NMMqjN32Y3uXJg@mail.gmail.com>
Subject: Re: Recovery after BAD_SEQID
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 19, 2015 at 6:48 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> I wrote yesterday about a RHEL6 bug, but I'd gotten some details wrong about
> the problem, so I'm starting new thread.
>
> It looks like getting BAD_SEQID back from an OPEN operation drops the state_owner
> which means that the state machine can't find or recover any other objects
> for that state_owner.  That can get the client into unrecoverable loops.  I
> can produce one of them with:
>
> 1) OPEN file1, OPEN file2
> 2) break the network for longer than the lease period
> 3) during recovery, have the server return BAD_SEQID for one of the OPENS
> 4) break the network again for longer than the lease period
> 5) WRITE to the file that recovered properly in #3
>
> This gets stuck in WRITE,NFS4ERR_EXPIRED.
>
> It looks like some cleanup is needed if we have to drop the whole
> state_owner.  Alternatively, does it make sense to just drop the objects in
> that sequence?
>
>

Ummm... Why are you seeing BAD_SEQID in the first place? That specific
error means that the client and server disagree on the sequencing of
the OPENs, which means there is a bug either on the client or on the
server.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
