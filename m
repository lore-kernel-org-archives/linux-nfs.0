Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:60551 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750Ab2DZGbr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 02:31:47 -0400
Message-ID: <4F98EBD1.2070808@parallels.com>
Date: Thu, 26 Apr 2012 10:31:45 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2] SUNRPC: skip dead but not buried clients on PipeFS
 events
References: <20120420141042.7205.62608.stgit@localhost6.localdomain6> <20120425173005.GD751@fieldses.org>
In-Reply-To: <20120425173005.GD751@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

25.04.2012 21:30, J. Bruce Fields написал:
> On Fri, Apr 20, 2012 at 06:11:02PM +0400, Stanislav Kinsbursky wrote:
>> v2: atomic_inc_return() was replaced by atomic_inc_not_zero().
>>
>> These clients can't be safely dereferenced if their counter in 0.
> I'm pretty confused by how these notifiers work....
>
> rpc_release_client decrements cl_count to zero temporarily, to have it
> immediately re-incremented by rpc_free_auth.
>
> So if we're called concurrently with rpc_release_client then it's sort
> of random whether someone gets this callback.
>
> Is that a problem?
>
> Also, is this an existing bug?  (In which case Trond should take it
> now.)

Sorry, I was mistaken in previous letter.
Yes, this is an existent bug.
I.e. without this patch notifier can dereference a client, which is 
actually dead already, but haven't deleted itself from the client's list.
And then notifier will try to work with this client and even release it 
at the end.

