Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38169
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752527Ab1G2TBg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 15:01:36 -0400
Date: Fri, 29 Jul 2011 15:01:33 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110729190133.GA10946@infradead.org>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <20110729155136.GB28306@infradead.org>
 <20110729185415.GA23061@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729185415.GA23061@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 29, 2011 at 02:54:15PM -0400, Jim Rees wrote:
> xfstests does require a small patch to work with NFSv4, which I can supply
> if anyone is interested.

Please send it to xfs@oss.sgi.com with a proper description and signoff.

> PLATFORM      -- Linux/x86_64 rhcl1 3.0.0-blk
> 
> 001      - output mismatch (see 001.out.bad)
> -iter 5 chain ... check ....................................
> +001 not run: this test requires a valid host fs for $SCRATCH_DEV
>  cleanup
> 002      [not run] this test requires a valid host fs for $SCRATCH_DEV
> 003      [not run] not suitable for this filesystem type: nfs
> 004      [not run] not suitable for this filesystem type: nfs
> 005      [not run] this test requires a valid host fs for $SCRATCH_DEV
> 006      [not run] this test requires a valid host fs for $SCRATCH_DEV
> 007      [not run] this test requires a valid host fs for $SCRATCH_DEV

It seems like you didn't set up the SCRATCH_DEV variable properly.

> Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>  kernel:------------[ cut here ]------------
> 
> Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>  kernel:invalid opcode: 0000 [#1] SMP 
> 
> Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>  kernel:Stack:
> 
> Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>  kernel:Call Trace:
> 
> Message from syslogd@rhcl1 at Jul 29 14:42:05 ...

Looks like we did find a bug in NFS.

