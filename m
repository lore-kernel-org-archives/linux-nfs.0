Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:16927 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556Ab2DLQGD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 12:06:03 -0400
Subject: Re: global openowner_id and lockowner_id
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1334246326.2237.59.camel@lade.trondhjem.org>
Date: Thu, 12 Apr 2012 12:05:58 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6DD87307-2E70-4BC0-8920-70B5D4C34D62@oracle.com>
References: <58E57AF8-1636-4017-93C0-8520488ED866@oracle.com> <1334245818.2237.55.camel@lade.trondhjem.org> <7212EB20-16EC-475E-993E-3F244C621AB0@oracle.com> <1334246326.2237.59.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 12, 2012, at 11:58 AM, Myklebust, Trond wrote:

> On Thu, 2012-04-12 at 11:54 -0400, Chuck Lever wrote:
>> On Apr 12, 2012, at 11:50 AM, Myklebust, Trond wrote:
>> 
>>> On Thu, 2012-04-12 at 11:42 -0400, Chuck Lever wrote:
>>>> Hi-
>>>> 
>>>> Changing the SETCLIENTID boot verifier so it is global for the whole client exposes a problem with how we allocate state owners.
>>>> 
>>>> A quick umount / mount sequence destroys all state on the client.  But since the client now always uses the same boot verifier and nfs_client_id4 string, the server no longer recognizes a client reboot.  FOr a fresh mount, the client may perform a SETCLIENTID, but it is treated as a callback update (state is not purged) if the client's lease has not yet expired.
>>>> 
>>>> Our state owners are generated from a pair of ida structures in the nfs_server for that mount.  They always start from zero after a mount operation.  Likewise, the sequence IDs for these state owners are also reset by umount / mount.  Note that each mount point gets a fresh nfs_server, so these structures are not retained across umount / mount.
>>>> 
>>>> This means umount / mount with no lease expiry starts to re-play state owners with reset sequence IDs.  Servers don't really care for that behavior.  I have a test case that reliably gets a BAD_SEQID error from a server after a quick umount / mount followed by a single file creation.
>>>> 
>>>> Now that we are about to switch to using more-or-less global SETCLIENTID boot verifiers, it seems to me that we really want a global openowner_id and lockowner_id as well.
>>>> 
>>>> The performance impact of such a change might be acceptable because we cache and reuse state owners now.
>>>> 
>>>> Thoughts?
>>> 
>>> That's a definite server bug. If the client holds no open state, then it
>>> is allowed to forget the open owner and start the sequence id from 0
>>> again. It is not required to remember sequence ids for open owners that
>>> aren't in use.
>>> 
>>> Our current client could easily trigger this bug even without a
>>> umount/mount.
>> 
>> The client is holding open state.  Here's the exact reproducer on my modified client:
>> 
>> 1.  mount server:/export /mnt
>> 2.  touch /mnt/newfile
>> 3.  umount /mnt
>> 4.  mount server:/export /mnt
>> 5.  touch /mnt/newfile2
>> 
>> Step 5 causes the client to replay an open owner with a reset sequence ID, and the server replies BAD_SEQID.
> 
> touch won't keep the file open. There is no open state once touch has
> finished executing.

OK, agreed.

> What you have exposed above is a _server_ bug. The server is _not_
> allowed to assume that the client will cache an open owner forever once
> it no longer holds any open state using that open owner. We had a loong
> discussion about this on the mailing list a few years ago with David
> Robinson being the person who formulated the above rule.

I'm not sure I would characterize this as a server bug just yet.  On OPEN, the server is allowed to tell the client it is using a bad sequence ID, and the client is supposed to recover by trying again with a different OO.  Our BAD_SEQID recovery logic appears to be broken, because our client goes into a loop retrying the OPEN with the same OO.  If recovery worked, this would all be perfectly transparent, I think.

I was taking a step back and wondering how the client chose the OO in the first place.

But you claimed above that our client could trigger this bug without a umount / mount sequence.  Do you have an example of how I might try that?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




