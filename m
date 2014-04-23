Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:44027 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbaDWW6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2014 18:58:01 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 23 Apr 2014 18:58:00 -0400
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1E35138C8046
	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 18:57:59 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3NMvxb19961836
	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 22:57:59 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3NMvwnc025075
	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 18:57:58 -0400
Date: Wed, 23 Apr 2014 17:57:57 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
Message-ID: <20140423225757.GA17353@us.ibm.com>
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
 <20140423202401.GA16168@us.ibm.com>
 <CALXu0UdVYtbKQqskETk9jEK3+=nFphUtFSP4i_ey=7WwZg3-XQ@mail.gmail.com>
 <20140423204405.GB16168@us.ibm.com>
 <CALXu0UdbSHfFM+tq2_zssMhiwZ1qMJdieNdvwtxz6k31CMWAUA@mail.gmail.com>
 <20140423211518.GA16506@us.ibm.com>
 <CALXu0UfjY288HZ_NHH_njs0iLhcY5Xn7NUJNYa9kL45m2YHfAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0UfjY288HZ_NHH_njs0iLhcY5Xn7NUJNYa9kL45m2YHfAw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cedric Blancher [cedric.blancher@gmail.com] wrote:
> On 23 April 2014 23:15, Malahal Naineni <malahal@us.ibm.com> wrote:
> > Cedric Blancher [cedric.blancher@gmail.com] wrote:
> >> On 23 April 2014 22:44, Malahal Naineni <malahal@us.ibm.com> wrote:
> >> > Cedric Blancher [cedric.blancher@gmail.com] wrote:
> >> >> On 23 April 2014 22:24, Malahal Naineni <malahal@us.ibm.com> wrote:
> >> >> > Cedric Blancher [cedric.blancher@gmail.com] wrote:
> >> >> >> Are there any options to improve the Linux NFSv4 performance over a
> >> >> >> high latency connection?
> >> >> >>
> >> >> >> We currently use Solaris/Illumos as NFSv4 server and client over a
> >> >> >> cross continental Internet connection. Latency is terrible (~220ms)
> >> >> >> but the counter this by running work in parallel so the latency is
> >> >> >> mostly mitigated.
> >> >> >>
> >> >> >> We now wish to migrate (short: Away from Oracle because support is
> >> >> >> basically unbearable) to Linux (tested SuSE 13.1 and current Fedora)
> >> >> >> and build times are 17 times (!!!) SLOWER than on Solaris/Illumos.
> >> >> >>
> >> >> >> Are there any tunables besides actimeo=300?
> >> >> >
> >> >> > rsize and wsize may help! You need to figure out if the read is the
> >> >> > issue or the write before you dig further.
> >> >>
> >> >> I already tried to tune rsize/wsize, making them both smaller or the
> >> >> maximum of 1048576 bytes, with no effect.
> >> >>
> >> >> One possible theory is that maybe something in Linux doesn't allow
> >> >> multiple requests to be issued in parallel and waits for each request
> >> >> to be completed before issuing the next one?
> >> >
> >> > Linux NFS client can issue I/Os in parallel. Should be limited by number
> >> > of RPC slots though.
> >>
> >> What controls the number of RPC slots? is there a tunable? Is there
> >> something to monitor the usage?
> >
> > sysctl sunrpc.tcp_slot_table_entries (if you are using tcp)
> 
> Its 16
> NFSv4 is tcp only
> 
> I tried to bump the value to 128 - without effect - but the change is
> not persistent across reboots. Is there something like Solaris
> /etc/system which the kernel reads to set these values?

Probably depends on your distro. Look at /etc/sysctl.conf if you have
that file.

> > Also, mountstats <mount-point> would be very helpful.
> 
> I don't have that command. likely my test machine is too old

Hmm, my RHEL6.4 has it. What nfs-utils package you have.

Regards, Malahal.

