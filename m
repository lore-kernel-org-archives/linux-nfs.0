Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:55800 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756047AbaELU7D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 16:59:03 -0400
Received: by mail-pa0-f52.google.com with SMTP id fa1so5263244pad.11
        for <linux-nfs@vger.kernel.org>; Mon, 12 May 2014 13:59:02 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFS: revalidate on open if dcache is negative.
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140512135019.56e5c465@notabene.brown>
Date: Mon, 12 May 2014 13:58:59 -0700
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <5C29EB03-6EF6-476C-AD25-97E0A3871C26@primarydata.com>
References: <20140512135019.56e5c465@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 11, 2014, at 20:50, NeilBrown <neilb@suse.de> wrote:

> 
> 
> NFS CTO semantics require that (absent a delegation) the server
> must be contacted at each open.
> 
> nfs_lookup_verify_inode() implements this when the dcache contains
> a positive cached entry.  However it is not called when the dcache
> contains a negative cached entry.  That path uses nfs_neg_need_reval()
> which doesn't impose CTO semantics.
> 
> So a sequence like:
> 
>   rm -f testfile
>   ls -l testfile
>   ssh $server touch testfile
>   cat testfile
> 
> will fail:
> 
>  cat: testfile: No such file or directory
> 
> an 'strace' will confirm that this resulted from an 'open' system
> call.
> 
> So add code to nfs_neg_need_reval implement CTO semantics much like
> that in nfs_lookup_verify_inode().

Hi Neil,

To me, close-to-open is about ensuring that the data and metadata caches for the file (or directory) in question are revalidated correctly on open (or opendir). Close-to-open semantics are enabled/disabled by the cto/nocto mount options (with cto being the default).

The lookup semantics are about ensuring that the namespace cache is consistent with what is on the server. They are controlled by the ‘lookupcache’ mount option, which defaults to the behaviour that you describe above (lookupcache=all). I believe that we have discussed changing the default to be lookupcache=positive, which would give the semantics that your patch enforces, but I believe the consensus was to keep the current behaviour.

Cheers
  Trond

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

