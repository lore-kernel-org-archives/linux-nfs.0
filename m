Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51395 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755485Ab1F1IHa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 04:07:30 -0400
Received: by iwn6 with SMTP id 6so4762924iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 01:07:30 -0700 (PDT)
Message-ID: <4E098BBC.3030007@tonian.com>
Date: Tue, 28 Jun 2011 11:07:24 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: quanli gui <gqlxj1987@gmail.com>
CC: Thomas Haynes <thomas@netapp.com>, nfsv4@ietf.org,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] nfs client bug?
References: <BANLkTinMhiYNiz2EP+yppxC7-MrtFa_xLg@mail.gmail.com>	<F84410BF-4426-4A85-891F-642F70955914@netapp.com> <BANLkTimZh2eCVLozyT8t_nkX08W=dx0mHg@mail.gmail.com>
In-Reply-To: <BANLkTimZh2eCVLozyT8t_nkX08W=dx0mHg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Since your client runs SUSE linux please send this to
linux-nfs@vger.kernel.org (please subscribe first if you aren't already)

Benny

On 2011-06-28 10:34, quanli gui wrote:
> There is some else mailing list about the nfsv4?
> 
> OSes are suse 11 enterprise server, the linux kernel version we are running is 2.6.31+pnfs.patch.
> Our test command is mount -t nfs4 -o minorversion=1 serverIP:/ /mnt/serverIP.
> 
> On Tue, Jun 28, 2011 at 1:17 PM, Thomas Haynes <thomas@netapp.com <mailto:thomas@netapp.com>> wrote:
> 
>     This mailing list is concerned with the protocol.
> 
>     You either want to contact your client or server provider. When you do so,
>     please make sure to mention which OSes and versions you are running.
> 
>     On Jun 27, 2011, at 9:01 PM, quanli gui wrote:
> 
>     > Hi,
>     > Recently I test the nfsv4 speed, I found that there is something wrong in the nfs client, that is the one nfs client can only provide 400MB/S to the server.
>     > My tests as follow:
>     > machine:one client, four server; hardware: all 16core, 16G memory, 5T disk; os: all suse 11 enterprise server, 2.6.31-pnfs-kernel; network: client, 10GE, server, 2GE(bond, 1GE*2);
>     > test method: on the client, mkdir four independent directory, mount the four server via nfsv4 protocol, every time increase one;
>     > test tool: iozone, or dd if=/dev/zero of=test count=20K,then cat test>/dev/null
>     > test result:(force on read speed, and watch the client/server network input/output by the sar command)
>     > 1 client vs 1 server: 200MB/S
>     > 1 client vs 2 server: 380MB/S, every server: 190MB/S
>     > 1 client vs 3 server: 380MB/S, every server: 130MB/S
>     > 1 client vs 4 server: 385MB/S, every server: 95MB/S
>     >
>     > From above, we found that 400MB/S is the max-speed for one client. This speed is the limition? How to increase this speed?
>     >
>     > _______________________________________________
>     > nfsv4 mailing list
>     > nfsv4@ietf.org <mailto:nfsv4@ietf.org>
>     > https://www.ietf.org/mailman/listinfo/nfsv4
> 
> 
> 
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
