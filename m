From: "Andrew Bell" <andrew.bell.ia@gmail.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 11:34:27 -0500
Message-ID: <e80abd30807150934tc14e793ydd7aae44b4c3111b@mail.gmail.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:26745 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYGOQea (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 12:34:30 -0400
Received: by qw-out-2122.google.com with SMTP id 3so177734qwe.37
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 09:34:27 -0700 (PDT)
In-Reply-To: <76bd70e30807150923r31027edxb0394a220bbe879b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 11:23 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> On Tue, Jul 15, 2008 at 11:58 AM, Peter Staubach <staubach@redhat.com> wrote:
>> If it is the notion described above, sometimes called head
>> of line blocking, then we could think about ways to duplex
>> operations over multiple TCP connections, perhaps with one
>> connection for small, low latency operations, and another
>> connection for larger, higher latency operations.
>
> I've dreamed about that for years.  I don't think it would be too
> difficult, but one thing that has held it back is the shortage of
> ephemeral ports on the client may reduce the number of concurrent
> mount points we can support.

Could one come up with a way to insert "small" ops somewhere in middle
of the existing queue, or are the TCP send buffers typically too deep
for this to do much good?  Seems like more than one connection would
allow "good" servers to handle requests simultaneously anyway.

Is there really that big a shortage of ephemeral ports?  I guess one
could do active connection management.

> One way to avoid the port issue is to construct an SCTP transport for
> NFS.  SCTP allows multiple streams on the same connection, effectively
> eliminating head of line blocking.

Waiting for SCTP sounds like a long-term solution, as server vendors
probably have little incentive.

Thanks for the ideas.  I'll have to see what kind of time I can get to
investigate this stuff.

-- 
Andrew Bell
andrew.bell.ia@gmail.com
