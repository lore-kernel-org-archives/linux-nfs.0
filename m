Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55084 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932881Ab2EOWK1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 18:10:27 -0400
Message-ID: <4FB2D447.50209@panasas.com>
Date: Wed, 16 May 2012 01:10:15 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Rick Macklem <rmacklem@uoguelph.ca>
CC: nfsv4 <nfsv4@ietf.org>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] commit thru DS at the bakeathon?
References: <2053705292.441561.1337119098800.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <2053705292.441561.1337119098800.JavaMail.root@erie.cs.uoguelph.ca>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/16/2012 12:58 AM, Rick Macklem wrote:

> Hi,
> 
> I was just wondering if anyone was going to have a pNFS server
> at the June bakeathon that does Files layout and requires
> "commit through the DS"?
> 


I bet it could be simple to implement with the Linux local-exp
pnfs server. (If not already supported)

> It's one piece I haven't implemented yet and, although I do plan
> on coding it, I was wondering if I should try and get it done in
> the next couple of weeks?
> 
> Just fyi, I'll have a FreeBSD NFSv4.0 server and a NFSv4.1 client that
>      includes pNFS using the files layout only there for testing.
>      (excluding support for "commit through DS" maybe?)
> 


Hey nice! a pnfs client for FBSD. Do you have a preliminary design
for multiple layout-drivers like in Linux with a vector table?

Should I be looking into objects implementation?

> Looking forward to the bakeathon, rick


Will not attend this time. Perhaps next time. Do you
have a public git tree for review?

Cheers
Boaz
