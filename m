Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758837Ab2D0Osr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 10:48:47 -0400
Date: Fri, 27 Apr 2012 10:48:40 -0400
From: Josh Boyer <jwboyer@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Add modalias for "nfs4"
Message-ID: <20120427144840.GB13189@zod.bos.redhat.com>
References: <20120427131031.GA13189@zod.bos.redhat.com>
 <20120427141918.GA15506@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120427141918.GA15506@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 10:19:18AM -0400, Jim Rees wrote:
> Josh Boyer wrote:
> 
>   When NFSv4 is configured, the support goes into the nfs.ko module.
>   However, nfs-utils seems to pass "nfs4" as the fileststem type for
>   NFSv4 mounts.
> 
> Weren't we going to change that to nfs and use nfsvers to select nfs4?

I have, approximately, no idea.  At least the version of nfs-utils found
in Fedora 17 and rawhide, it's still using "nfs4".   I believe that is
nfs-utils-1.2.6-rc6 based.

josh
