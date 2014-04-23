Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:53825 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755714AbaDWUYH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2014 16:24:07 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 23 Apr 2014 16:24:06 -0400
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 68C606E801C
	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 16:23:56 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3NKO3BC8192090
	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 20:24:03 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3NKO2Lw029602
	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 16:24:03 -0400
Date: Wed, 23 Apr 2014 15:24:01 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
Message-ID: <20140423202401.GA16168@us.ibm.com>
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cedric Blancher [cedric.blancher@gmail.com] wrote:
> Are there any options to improve the Linux NFSv4 performance over a
> high latency connection?
> 
> We currently use Solaris/Illumos as NFSv4 server and client over a
> cross continental Internet connection. Latency is terrible (~220ms)
> but the counter this by running work in parallel so the latency is
> mostly mitigated.
> 
> We now wish to migrate (short: Away from Oracle because support is
> basically unbearable) to Linux (tested SuSE 13.1 and current Fedora)
> and build times are 17 times (!!!) SLOWER than on Solaris/Illumos.
> 
> Are there any tunables besides actimeo=300?

rsize and wsize may help! You need to figure out if the read is the
issue or the write before you dig further.

Regards, Malahal.

