From: Peter Staubach <staubach@redhat.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 11:58:32 -0400
Message-ID: <487CC928.8070908@redhat.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Andrew Bell <andrew.bell.ia@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028AbYGOP6g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 11:58:36 -0400
In-Reply-To: <e80abd30807150834m47a1b86cle39885150f1d5bfd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Bell wrote:
> Hi,
>
> I have a RHEL 5 system that exhibits less than wonderful performance
> when copying large files from/to an NFS filesystem.  When the copy is
> taking place, other access to the filesystem is painfully slow.  I
> would like to have the filesystem react well to small requests while a
> large request is taking place.
>
> A couple of questions:
>
> Is this a reasonable expectation?
>
>   

Well, yes, I think that it would be a reasonable expectation.
I know that I would certainly like for it to be true.  :-)

That said, this is a common situation, but not one that we've
had/made the time to resolve yet.

> Is this perhaps an I/O scheduling issue that isn't specific to NFS,
> but shows up there because of the latency of my NFS setup?
>
>   

Could be.  Nothing is impossible.  That said...

> Is this most likely a client issue, a server issue or a combination?
>
>   

It could be either one, both, or the network even.

It could easily just be the architecture of the NFS client
solution, in that it is sharing a single TCP connection for
both data operations and also metadata operations.  The
metadata operations can get behind the larger data operations
in the TCP stream, thus increasing their latencies.

> Do you have recomendations on the best way to determine what is
> happening?  Are there existing tools to monitor active IO/NFS
> requests/responses and any relevant queues?
>
>   

Perhaps ensure that the local file system on the server is
performing well and that there are no obvious hot spots or
that the activity is causing the file system to thrash.

Some file systems, such as ext3, tend to bottleneck in the
journaling code, so that might be an area of the local file
system to consider.

> Thanks for any info/ideas before I get in too deep :)

We could use some idea of the activities that are occurring
when you encounter the slowness that you are concerned about.

If it is the notion described above, sometimes called head
of line blocking, then we could think about ways to duplex
operations over multiple TCP connections, perhaps with one
connection for small, low latency operations, and another
connection for larger, higher latency operations.

    Thanx...

       ps
