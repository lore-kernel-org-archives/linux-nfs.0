Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from snippy.nobiscuit.com ([50.17.199.227]:37266 "EHLO
	snippy.nobiscuit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab1FEBjK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jun 2011 21:39:10 -0400
Date: Sun, 5 Jun 2011 01:39:09 +0000
From: Nigel Roberts <nigel@nobiscuit.com>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 server on ARM
Message-ID: <20110605013909.GA14721@snippy.nobiscuit.com>
References: <20110529132515.GB19451@snippy.nobiscuit.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110529132515.GB19451@snippy.nobiscuit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 29 May 2011 at 13:25:15 +0000, Nigel Roberts wrote:

> I've run into a problem with running an nfsv4 server on a Marvell
> Kirkwood (armv5tel) platform. When copying a large file (>1GB) to 
> the NFS  server, thewrite speed will suddenly slow down to ~750kB/s 
> and the CPU wait will jump to 100% for the remainder of the transfer.

I was to try to spend some time figuring this this out this weekend, but
after updating to 2.6.39.1 for other reasons the problem seems to have
been resolved and I can no longer produce it. I can't see anything in
the changelog that might be the reason for this, but I'm wondering if
it might be the client (ubuntu natty) that was triggering the issue. If
it does start happening again I will be sure to get some packet
captures.

This is just a message for people with similar problems going through
the archives.

Regards,
Nigel
