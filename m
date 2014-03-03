Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35523 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980AbaCCPqk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 10:46:40 -0500
Received: by mail-ie0-f172.google.com with SMTP id as1so5798273iec.3
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 07:46:39 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Temporary hangs when using locking with apache+nfsv4
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140303104315.1f949cb4@tlielax.poochiereds.net>
Date: Mon, 3 Mar 2014 10:46:37 -0500
Cc: Dennis Jacobfeuerborn <dennisml@conversis.de>, linux-nfs@vger.kernel.org
Message-Id: <2D6DA167-FD44-4D73-8D55-8084A8DF95BE@primarydata.com>
References: <53141788.9030209@conversis.de> <20140303104315.1f949cb4@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 3, 2014, at 10:43, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 03 Mar 2014 06:47:52 +0100
> Dennis Jacobfeuerborn <dennisml@conversis.de> wrote:
> 
>> Hi,
>> I'm experimenting with using NFSv4 as storage for web servers and while 
>> regular file access seems to work fine as soon as I bring flock() into 
>> play things become more problematic.
>> I've create a tiny test php script that basically opens a file, locks it 
>> using flock(), writes that fact into a log file (on a local filesystem), 
>> performs a usleep(1000), writes into the log that it is about to unlock 
>> the file and finally unlocks it.
>> I invoke that script using ab with a concurrency of 20 for a few 
>> thousand requests.
>> 
> 
> Is all the activity from a single client, or are multiple clients
> contending for the lock?
> 
>> The result is that while 99% of the request respond quickly a few 
>> request seem to hang for up to 30 seconds. According to the log file 
>> they must eventually succeed since I see all expected entries and the 
>> locking seems to work as well since all entries are in the expected order.
>> 
>> Is it expected that these long delays happen? When I comment the locking 
>> function out these hangs disappear.
>> Are there some knobs to tune NFS and make it behave better in these 
>> situations?
>> 
> 
> NFSv4 locking is inherently unfair. If you're doing a blocking lock,
> then the client is expected to poll for it. So, long delays are
> possible if you just happen to be unlucky and keep missing the lock.
> 
> There's no knob to tune, but there probably is room for improvement in
> this code. In principle we could try to be more aggressive about
> getting the lock by trying to wake up one or more blocked tasks whenever
> a lock is released. You might still end up with delays, but it could
> help improve responsiveness.

…or you could implement the NFSv4.1 lock callback functionality. That would scale better than more aggressive polling.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

