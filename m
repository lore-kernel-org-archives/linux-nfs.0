Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:17424 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab2DOT6A convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Apr 2012 15:58:00 -0400
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4F8B1B7B.3040304@itwm.fraunhofer.de>
Date: Sun, 15 Apr 2012 15:57:32 -0400
Cc: Jeff Layton <jlayton@redhat.com>, Malahal Naineni <malahal@us.ibm.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, pstaubach@exagrid.com, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de
Message-Id: <F7D07FEC-4CA3-471F-8043-0DB899660BBB@oracle.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <20120413150518.GA1987@us.ibm.com> <20120413114236.0e557e01@tlielax.poochiereds.net> <4F8B1B7B.3040304@itwm.fraunhofer.de>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 15, 2012, at 3:03 PM, Bernd Schubert wrote:

> On 04/13/2012 05:42 PM, Jeff Layton wrote:
>> (note: please don't trim the CC list!)
>> 
>> Indefinitely does make some sense (as Peter articulated in his original
>> set). It's possible you could race several times in a row, or a server
>> misconfiguration or something has happened and you have a transient
>> error that will eventually recover. His assertion was that any limit on
>> the number of retries is by definition wrong. For NFS, a fatal signal
>> ought to interrupt things as well, so retrying indefinitely has some
>> appeal there.
>> 
>> OTOH, we do have to contend with filesystems that might return ESTALE
>> persistently for other reasons and that might not respond to signals.
>> Miklos pointed out that some FUSE fs' do this in his review of Peter's
>> set.
>> 
>> As a purely defensive coding measure, limiting the number of retries to
>> something finite makes sense. If we're going to do that though, I'd
>> probably recommend that we set the number of retries be something
>> higher just so that this is more resilient in the face of multiple
>> races. Those other fs' might "spin" a bit in that case but it is an
>> error condition and IMO resiliency trumps performance -- at least in
> this case.
> 
> I am definitely voting against an infinite number of retries. I'm
> working on FhGFS, which supports distributed meta data servers. So when
> a file is moved around between directories, its file handle, which
> contains the meta-data target id might become invalid.

Doesn't Jeff's recovery mechanism resolve this situation?  The client does a fresh lookup, so shouldn't it get the new FH at that point?  If there is no possible way for the client to discover the new FH, then ESTALE recovery should probably be finite.

> As NFSv3 is
> stateless we cannot inform the client about that and must return ESTALE
> then. NFSv4 is better, but I'm not sure how well invalidating a file
> handle works.  So retrying once on ESTALE might be a good idea, but
> retrying forever is not.
> Also, what about asymmetric HA servers? I believe to remember that also
> resulted in ESTALE. So for example server1 exports /home and /scratch,
> but on failure server2 can only take over /home and denies access to
> /scratch.

Retrying forever is bad only if we think there are cases where there is no possible recovery action for the client, or the ESTALE signals a condition that is not temporary.

It is temporary, for instance, when an administrator takes an exported volume offline; at some point, that volume will be brought back online.  Maybe it is better generally for the client to retry indefinitely instead of causing applications to fail.

Retrying forever is exactly what we do for "hard" NFS mounts, for example, and for many types of NFSv4 state recovery.  Philosophically, how is this situation different?

It would be reasonable, at least, to insert a backoff delay in the retry logic.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




