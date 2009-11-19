Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:51490 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792AbZKSUWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Nov 2009 15:22:54 -0500
Message-ID: <4B05A91D.1090305@krogh.cc>
Date: Thu, 19 Nov 2009 21:22:53 +0100
From: Jesper Krogh <jesper@krogh.cc>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Greg Banks <gnb@fmeh.org>
Subject: Re: 2.6.31 under "heavy" NFS load.
References: <4AF86DE4.5010607@krogh.cc> <20091110184126.GD15000@fieldses.org> <4AF9B994.8040301@krogh.cc>
In-Reply-To: <4AF9B994.8040301@krogh.cc>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jesper Krogh wrote:
> J. Bruce Fields wrote:
>> On Mon, Nov 09, 2009 at 08:30:44PM +0100, Jesper Krogh wrote:
>>> When a lot (~60 all on 1GbitE) of NFS clients are hitting an NFS server
>>> that has an 10GbitE NIC sitting on it I'm seeing high IO-wait load
>>> (>50%) and load number over 100 on the server. This is a change since
>>> 2.6.29 where the IO-wait load under similar workload was less than 10%.
>>>
>>> The system has 16 Opteron cores.
>>>
>>> All data the NFS-clients are reading are "memory recident" since they
>>> are all reading off the same 10GB of data and the server has 32GB of
>>> main memory dedicated to nothing else than serving NFS.
>>>
>>> A snapshot of top looks like this:
>>> http://krogh.cc/~jesper/top-hest-2.6.31.txt
>>>
>>> The load is generally alot higher than on 2.6.29 and it "explodes" to
>>> over 100 when a few processes begin utillizing the disk while serving
>>> files over NFS. "dstat" reports a read-out of 10-20MB/s from disk which
>>> is close to what I'd expect. and the system delivers around 600-800MB/s
>>> over the NIC in this workload.
>> Is that the bandwidth you get with 2.6.31, with 2.6.29, or with both?
> 
> Without being able to be fully accurate, I have a strong feeling that
> the comparative numbers on 2.6.29 were more around 800-1000MB/s. But
> this isn't based on any measurements so dont put too much into it. I'll
> try to make up something that I can use for testing over multiple
> kernel-versions.
> 
>> Are you just noticing a change in the statistics, or are there concrete
>> changes in the performance of the server?
> 
> Interactivity on the console is alot worse. Still usable, but top takes
> ~5s to start up on 2.6.31 where I didn't remember any lags on 2.6.29 (so
> less than 2s).
> 
>>> Sorry that I cannot be more specific, I can answer questions on a
>>> running 2.6.31 kernel, but I cannot reboot the system back to 2.6.29
>>> just to test since the system is "in production". I tried 2.6.30 and it
>>> has the same pattern as 2.6.31, so based on that fragile evidence the
>>> change should be found in between 2.6.29 and 2.6.30. I hope a "wague"
>>> report is better than none.
>> Can you test whether this helps?
> 
> I'll schedule testing..

Ok, I still haven't had the "excact same" workload put on the host, but
it has been running on the patched kernel for 8 days now and I havent
seen load numbers over 32 while service 1100MB/s over NFS (dd'ing 512
bytes blocks out of the server from the clients) while doing local disk
IO for an iowait of ~25% (4 cores sucking what they can). This workload
is "similar" to the one sending it to load numbers of over 100 earlier.

So I'm confident that the problem is solved by reverting the patch.

-- 
Jesper
