Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56224 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755737AbeEaRe4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 13:34:56 -0400
Date: Thu, 31 May 2018 13:34:56 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Shawn Lu (shawlu)" <shawlu@cisco.com>
Cc: Joshua Watt <jpewhacker@gmail.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Is "unmount -f"  worked as expected?
Message-ID: <20180531173456.GE1298@fieldses.org>
References: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
 <0dae4862d6e5b754ba8f90a6391b6645fdf6889a.camel@gmail.com>
 <EE6D39C5-09BB-4133-9CF5-674038E1538F@cisco.com>
 <20180531151819.GC1298@fieldses.org>
 <C8362635-4E93-4C96-9827-E241565D27DF@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C8362635-4E93-4C96-9827-E241565D27DF@cisco.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2018 at 04:51:49PM +0000, Shawn Lu (shawlu) wrote:
> >On 5/31/18, 8:18 AM, "bfields@fieldses.org" <bfields@fieldses.org> wrote:
>  >  > One case is involved with  cross mounted nfs from different host.
>     
>  >  Note: in theory I think there are some deadlocks possible if client and
>  >   server mount each other.  (Each host could be waiting on the other one
>  >   to process writes before it can free memory that it needs to make
>  >   progress.)
> 
> Yes.  I hope aggressive umount  will  help by setting a very short grace period and timeout before umount.

No, the deadlock isn't an unmounting problem, it's a problem that could
happen during normal operation.  I don't know if it's easy to reproduce.
You'd probably need one or both hosts to be writing to NFS very quickly.

--b.
