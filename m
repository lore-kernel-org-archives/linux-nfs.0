Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:65047 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab1F3Ccb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 22:32:31 -0400
Received: by gxk21 with SMTP id 21so700755gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 19:32:30 -0700 (PDT)
In-Reply-To: <4E0B52BB.8090003@tonian.com>
References: <BANLkTi=xcQseTx8BTWEzg-1DO=ayJuMLrw@mail.gmail.com>
	<4E0B52BB.8090003@tonian.com>
Date: Thu, 30 Jun 2011 10:32:29 +0800
Message-ID: <BANLkTinxF+obzedP+xupMCDZcgRTFDsQMg@mail.gmail.com>
Subject: Re: [nfsv4]nfs client bug
From: quanli gui <gqlxj1987@gmail.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, "Mueller, Brian" <bmueller@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When I use the iperf tools for one client to 4 ds, the network
throughput is 890MB/S. It reflect that it is indeed 10GE non-blocking.

a. about block size, I use bs=1M when I use dd
b. we indeed use the tcp (doesn't the nfsv4 use the tcp defaultly?)
c. the jumbo frames is what? how set mtu automatically?

Brian, do you have some more tips?


On Thu, Jun 30, 2011 at 12:28 AM, Benny Halevy <bhalevy@tonian.com> wrote:
>
> Hi,
>
> First, please use plain text only when sending to linux-nfs@vger.kernel.org
> as multi-part / html messages are automatically blocked by the spam filter.
>
> I'm not so sure that the nfs client is to blame for the performance
> you're seeing.  The problem could arise from too small of a block size
> by dd / iozone
>
> I'd try:
> a. using a larger block size (e.g.  dd bs=4096k)
> b. tuning your tcp better for high bandwidth
> c. using jumbo frames all the way, and making sure that the mtu is discovered
> automatically and set properly to 9000.
>
> Also, what's you network look like?
> what's the switch you're using
> is it indeed 10 Gbps non-blocking
> are there any linecard / chip bottlenecks or over subscription
>
> Do you see better throughput with iperf?
>
> Brian, you's probably have even more tips and tricks :)
>
> Regards,
>
> Benny
>
> On 2011-06-28 11:26, quanli gui wrote:
> > Hi,
> > Recently I test the nfsv4 speed, I found that there is something wrong in
> > the nfs client, that is the one nfs client can only provide 400MB/S to the
> > server.
> > My tests as follow:
> > machine:one client, four server; hardware: all 16core, 16G memory, 5T disk;
> > os: all suse 11 enterprise server, 2.6.31-pnfs-kernel; network: client,
> > 10GE, server, 2GE(bond, 1GE*2);
> > test method: on the client, mkdir four independent directory, mount the four
> > server via nfsv4 protocol, every time increase one;
> > test tool: iozone, or dd if=/dev/zero of=test count=20K,then cat
> > test>/dev/null
> > test result:(force on read speed, and watch the client/server network
> > input/output by the sar command)
> > 1 client vs 1 server: 200MB/S
> > 1 client vs 2 server: 380MB/S, every server: 190MB/S
> > 1 client vs 3 server: 380MB/S, every server: 130MB/S
> > 1 client vs 4 server: 385MB/S, every server: 95MB/S
> >
> > From above, we found that 400MB/S is the max-speed for one client. This
> > speed is the limition? How to increase this speed?
> >
>
