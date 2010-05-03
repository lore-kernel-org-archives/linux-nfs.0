Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:34485 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757058Ab0ECVOL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 17:14:11 -0400
Received: by pzk42 with SMTP id 42so381369pzk.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 14:14:10 -0700 (PDT)
In-Reply-To: <1272914702.7559.13.camel@localhost.localdomain>
References: <l2wdc64e7231005030953xb72ad73az3f883167a1a637c8@mail.gmail.com>
	 <20100503185650.GA9864@fieldses.org>
	 <1272914702.7559.13.camel@localhost.localdomain>
Date: Mon, 3 May 2010 17:14:10 -0400
Message-ID: <t2ndc64e7231005031414ob1ca0ebaze725bb73e712234d@mail.gmail.com>
Subject: Re: Proxy
From: maillists0@gmail.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 3, 2010 at 3:25 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Mon, 2010-05-03 at 14:56 -0400, J. Bruce Fields wrote:
>> On Mon, May 03, 2010 at 12:53:15PM -0400, maillists0@gmail.com wrote:
>> > With NFS4's support for referrals and Kerberos, it seems like the
>> > original reasons to prevent re-exporting of an NFS share might no
>> > longer exist. With fs-proxy making its way into the mainline kernel
>> > and things like cachefilesd, there are also very good reasons to allow
>> > it. A proxy server with a persistent cache could give the ability to
>> > robustly use shares across a WAN or do failover pairs with no need for
>> > more complex replication. Speaking as an end-user, this would be very
>> > desirable.
>> >
>> > I see that others have implemented proxies with user-space NFS, which
>> > seems reasonable but not optimal. What is the obstacle to allowing
>> > re-exports with the standard nfs implentation? Is it possible at the
>> > moment to patch a kernel to make this work? Anyone have experience
>> > with it? Any input is appreciated.
>>
>> It's probably possible, but some kernel hacking would be required.
>>

Have a look at this old thing from 2006:
http://www.usenix.org/event/fast07/tech/full_papers/gulati/gulati_html/nache.html
. They claim to have implemented a proxy with only the tools I
mentioned above, along with their own modified version of nfs to allow
multi-hops.

I have a workload of lots of reads/almost no writes, and their
approach makes sense. It would be a great feature. Is something
missing from that paper that makes it unrealistic?
