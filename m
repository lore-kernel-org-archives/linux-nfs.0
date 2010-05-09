From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/8] nfsd4: keep the client from expiring while in use
 by nfs41 compounds
Date: Sun, 09 May 2010 09:30:31 +0300
Message-ID: <4BE65687.8050806@panasas.com>
References: <4BE0A1AE.4040905@panasas.com> <20100507223836.GO19142@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34022 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab0EIGaf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 May 2010 02:30:35 -0400
Received: by bwz19 with SMTP id 19so1212825bwz.21
        for <linux-nfs@vger.kernel.org>; Sat, 08 May 2010 23:30:34 -0700 (PDT)
In-Reply-To: <20100507223836.GO19142@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 08, 2010, 1:38 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Wed, May 05, 2010 at 01:37:34AM +0300, Benny Halevy wrote:
>> Bruce,
>>
>> The following patchset changes the scope of the sessionid spin lock
>> to cover both sessions and the client lru list and it introduces a
>> new reference count on the client that's manipulated under that new
>> client lock (not requiring the state mutex).
>>
>> It's tested to pass connectathon tests as well as explicit session destroy
>> and implicit client expiry when the client is blown away.
>> However, I haven't tested the gist of this patchset which is to get
>> the client to perform a long enough compound during which it might time out...
> 
> Yeah, I'm not sure how to test that.  Create a temporary patch
> introducign a "delay X seconds" compound op, then teach pynfs to send
> those timed to coincide with client-reboot exchangeid's or the end of a
> client lease?

That should do for a one time test.
For regression testing I think we need a better way of injecting
a timeout longer than the lease period.

> 
> So if I understand the intention of these patches right: behavior in the
> case of something explicitly destroys a client (e.g. client-rebooting
> exchangeid) is to partially destroy the client, but allow any concurrent
> compound to attempt to continue processing with the near-dead client?
> 

Correct.  The intentions are:
1. Make the laundromat process ignore clients that are in
use by a 4.1 session.
2. Renew the client when the compound ends, rather than when it begins.
3. Unhash the client when it's expired explicitly but don't destroy it
until there's no reference to it.

>> [PATCH 1/8] nfsd4: rename sessionid_lock to client_lock
>> [PATCH 2/8] nfsd4: fold release_session into expire_client
>> [PATCH 3/8] nfsd4: use list_move in move_to_confirmed
>> [PATCH 4/8] nfsd4: extend the client_lock to cover cl_lru
>> [PATCH 5/8] nfsd4: refactor expire_client
>> [PATCH 6/8] nfsd4: introduce nfs4_client.cl_refcount
>> [PATCH 7/8] nfsd4: keep a reference count on client while in use
>>
>> [PATCH 8/8] nfsd41: cstate->session can NULL in nfsd4_destroy_session
>> I think this was introduced in: 26c0c75 nfsd4: fix unlikely race in session replay case
>> though I'm not sure how it ever worked correctly...
> 
> Me neither.  I've got a similar patch in my tree.

Heh, I see.
5d4cec2 nfsd4: fix bare destroy_session null dereference

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

