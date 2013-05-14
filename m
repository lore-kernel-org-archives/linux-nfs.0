Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([143.182.124.21]:8820 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758558Ab3ENWGp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 May 2013 18:06:45 -0400
From: "Dilger, Andreas" <andreas.dilger@intel.com>
To: "james.vanns@framestore.com" <james.vanns@framestore.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [Lustre-devel] Export over NFS sets rsize to 1MB?
Date: Tue, 14 May 2013 22:06:08 +0000
Message-ID: <CDB80F65.32491%andreas.dilger@intel.com>
In-Reply-To: <1182911409.19669249.1368544019962.JavaMail.root@framestore.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013/14/05 9:07 AM, "James Vanns" <james.vanns@framestore.com> wrote:
>> On 2013/13/05 7:19 AM, "James Vanns" <james.vanns@framestore.com>
>> wrote:
>> >Hello dev list. Apologies for a post to perhaps the wrong group but
>> >I'm having a bit of difficulty locating any document or wiki describing
>> >how and/or where the preferred read and write block size for NFS
>> >exports of a Lustre filesystem are set to 1MB?
>> 
>> 1MB is the RPC size and "optimal IO size" for Lustre.  This would
>> normally be exported to applications via the stat(2) "st_blksize" field,
>> though it is typically 2MB (2x the RPC size in order to allow some
>>pipelining).  I suspect this is where NFS is getting the value, since
>>it is not passed up via the statfs(2) call.
>
>Hmm. OK. I've confirmed it isn't from any struct stat{} attribute
>(st_blksize
>is still just 4k) but yes, our RPC size is 1MB. It isn't coming from
>statfs()
>or statvfs() either.

I've CC'd the Linux NFS mailing list, since I don't know enough about the
NFS client/server code to decide where this is coming from either.

James, what kernel version do you have on the Lustre clients (NFS servers)
and on the NFS clients?

>> >Basically we have two Lustre filesystems exported over NFSv3. Our
>> >lustre block size is 4k and the max r/w size is 1MB. Without any
>> >special rsize/wsize options set for the export the default one
>> >suggested to clients (MOUNT->FSINFO RPC) as the preferred
>> >size is set to 1MB. How does Lustre figure this out? Other
>> >non-Lustre exports are generally much less; 4, 8, 16 or 32 kilobytes.
>> 
>> Taking a quick look at the code, it looks like NFS TCP connections
>> all have a maximum max_payload of 1MB, but this is limited in a number
>>of places in the code by the actual read size, and other maxima (for
>> which I can't easily find the source value).
>
>Yes it seems that 1MB is the maximum but also the optimal or preferred.
>
>> >Any hints would be appreciated. Documentation or code paths welcome
>> >as are annotated /proc locations.
>> 
>> To clarify from your question - is this large blocksize causing a
>> performance problem?  I recall some applications having problems with
>> stdio "fread()" and friends reading too much data into their buffers
>> if they are doing random IO.  Ideally stdio shouldn't be reading more
>> than it needs when doing random IO.
>
>We're experiencing what appears to be (as of yet I have no hard evidence)
>contention due to connection 'hogging' for these large reads. We have a
>set
>of 4 NFS servers in a DNS round-robin all configured to serve up our
>Lustre
>filesystem across 64 knfsds (per host). It's possible that we simply don't
>have enough hosts (or knfsds) for the #clients because many of the clients
>will be reading large amounts of data (1MB at a time) and therefore
>preventing
>other queued clients from getting a look-in. Of course this appears to
>the user
>as just a very slow experience.
>
>At the moment, I'm just trying to understand where this 1MB is coming
>from!
>The RPC transport size (I forgot to confirm - yes, we're serving NFS over
>TCP) is 1MB for all other 'regular' NFS servers yet their r/wsize are
>quite different.
>
>Thanks for the feedback and sorry I can't be more accurate at the moment
>:\

It should also be possible to explicitly mount the clients with rsize=65536
and wsize=65536, but it would be better to understand the cause of this.

>> At one time in the past, we derived the st_blksize from the file
>> stripe_size, but this caused problems with the NFS "Connectathon" or
>> similar because the block size would change from when the file was
>>first opened.  It is currently limited by LL_MAX_BLKSIZE_BITS for all
>> files, but I wouldn't recommend reducing this directly, since it would
>> also affect "cp" and others that also depend on st_blksize for the
>> "optimal IO size".  It would be possible to reintroduce the per-file
>> tunable in ll_update_inode() I think.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division


