Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:54690 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbaCJXXq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 19:23:46 -0400
Received: by mail-qc0-f178.google.com with SMTP id i8so8608631qcq.23
        for <linux-nfs@vger.kernel.org>; Mon, 10 Mar 2014 16:23:46 -0700 (PDT)
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: NFS4 patch 08/20 (BAD_SEQID recovery)
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <531DF5B4.9050001@pml.ac.uk>
Date: Mon, 10 Mar 2014 19:23:44 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <0BE71BDE-FFFB-4124-B037-8ABBD5C20455@primarydata.com>
References: <53199445.3010808@pml.ac.uk> <69B89FEE-5B58-468F-95CE-B384033B2E65@primarydata.com> <531DF5B4.9050001@pml.ac.uk>
To: Ben Taylor <benj@pml.ac.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 10, 2014, at 13:26, Ben Taylor <benj@pml.ac.uk> wrote:

> Hi Trond
> 
> On 07/03/14 13:05, Trond Myklebust wrote:
>>> Can anyone tell me what happened to this patch please? Was it lost or
>>>> superseded?
>> It was superseded by commit 95b72eb0bdef6 (NFSv4: Ensure we do not reuse open owner names), which is available in linux 3.4 and newer.
> 
> Many thanks. That's a puzzle then, because we're running 3.9 and up and
> already have that patch (I've checked).
> 
> I've attached my Wireshark dump (or at least a subset of it -
> unfortunately I don't have the original call, the dump I've got is all
> the same) - don't know if this tells you anything it doesn't tell me?
> I'm not exactly experienced at reading these things!
> 

It looks as if the client is trying to convert a delegation into an open stateid as part of returning that delegation, but the server is disputing the sequence id value.
What server is this?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

