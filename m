Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754915AbdJQU3y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 16:29:54 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4.1: Detect and retry after OPEN and
 CLOSE/DOWNGRADE race
Date: Tue, 17 Oct 2017 16:29:53 -0400
Message-ID: <DFE86ADF-F143-4284-BBF2-2B04BDBC743C@redhat.com>
In-Reply-To: <1508264788.11156.11.camel@primarydata.com>
References: <cover.1508248965.git.bcodding@redhat.com>
 <fb76d86caca02c277eea7cb1d469c209b59d06ab.1508248965.git.bcodding@redhat.com>
 <1508255361.3718.17.camel@primarydata.com>
 <8384C212-F32B-4F5A-B522-A8F08108DA58@redhat.com>
 <1508262139.6260.7.camel@primarydata.com>
 <62F4199A-60AB-4CC1-990F-8BA1BCC39482@redhat.com>
 <1508264788.11156.11.camel@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 Oct 2017, at 14:26, Trond Myklebust wrote:
> On Tue, 2017-10-17 at 13:52 -0400, Benjamin Coddington wrote:
>> Ah, yuck.  I read 8.2.2:
>>
>>    When such a set of locks is first created, the server returns a
>>    stateid with seqid value of one.
>>
>> .. and went from there.  Is this a conflict in the spec?
>>
>
> Hmm... I note that the equivalent section 2.2.16 in RFC7530 has been
> changed to remove the bit about the starting value of seqid being
> undefined.
>
> So, if the spec allows us to rely on the seqid always being initialised
> to 1, then we might at least be able to detect that we have to replay
> the open.
> One way to do so might be to keep a count of the number of outstanding
> seqids, and then force OPEN_DOWNGRADE/CLOSE to wait until that number
> hits 0 (or until a state recovery is started).

I can take that approach for another spin, but due to other priorities, I'll
likely not come back to this until next week.  Thanks for your comments.

Ben
