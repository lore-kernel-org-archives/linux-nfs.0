From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
	over NFS
Date: Wed, 13 May 2009 14:16:42 -0400
Message-ID: <b4ff356f0905131116o48181ccu4786578cc72c8ceb@mail.gmail.com>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <b4ff356f0905130920v184ab529mb52a4346d4c77c14@mail.gmail.com>
	 <20090513093229.097b47d2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Moyer <jmoyer@redhat.com>, Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:41179 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755452AbZEMSQm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 14:16:42 -0400
In-Reply-To: <20090513093229.097b47d2.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2009 at 12:32 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 13 May 2009 12:20:57 -0400 Olga Kornievskaia <aglo-vtMw8L3fJ9tyDzI6CaY1VQ@public.gmane.org=
=2Eedu> wrote:
>
>> I believe what you are seeing is how well TCP autotuning performs.
>> What old NFS code was doing is disabling autotuning and instead usin=
g
>> #nfsd thread to scale TCP recv window. You are providing an example =
of
>> where setting TCP buffer sizes outperforms TCP autotuning. While thi=
s
>> is a valid example, there is also an alternative example of where ol=
d
>> NFS design hurts performance.
>
> <scratches head>
>
> Jeff's computer got slower. =A0Can we fix that?

We realize that decrease performance is a problem and understand that
reverting the patch might be the appropriate course of action!

But we are curious why this is happening. Jeff if it's not too much tro=
uble
could you generate tcpdumps for both cases. We are curious what are
the max window sizes in both cases? Also could you give us your tcp and
network sysctl values for the testing environment (both client and serv=
er
values) that you can get with "sysctl -a | grep tcp" and also
" | grep net.core".


Poor performance using TCP autotuning can be demonstrated outside
of NFS but using Iperf. It can be shown that iperf will work better if =
"-w"
flag is used. When this flag is set, Iperf calls setsockopt() call whic=
h in
the kernel turns off autotuning.

As for fixing this it would be great if we could get some help from the
TCP kernel folks?

Another thing I should mention is that the proposed NFS patch does
reach into the TCP buffers because we need to make sure the recv buffer
is big enough to receive an RPC. To use autotuning NFS would
have to rely on the system-wide sysctl values. One way to ensure
that an RPC would fit is to then increase system-wide default TCP recv
buffer but then all connection would be using value. We thought that
instead of imposing such requirement we internally set the buffer
size big enough.
