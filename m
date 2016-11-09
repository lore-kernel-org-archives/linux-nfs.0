Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:34642 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbcKIL5K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 06:57:10 -0500
Received: by mail-qt0-f180.google.com with SMTP id n6so125225299qtd.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2016 03:57:10 -0800 (PST)
Message-ID: <1478692626.2394.9.camel@redhat.com>
Subject: Re: Question about nfsdcltrack --storagedir
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Wed, 09 Nov 2016 06:57:06 -0500
In-Reply-To: <87k2cdmi26.fsf@notabene.neil.brown.name>
References: <87k2cdmi26.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-11-09 at 14:46 +1100, NeilBrown wrote:
> Hi,
>  I notice that nfsdcltrack has a "--storagedir" option.
>  I wonder how this can be used, given the nfsdcltrack is only(?) called
>  from the kernel and there is no(?) mechanism to pass extra options.
> 
>  In a clustered-server context it would make sense(?) to share the
>  database between cluster nodes and it is easiest to do this if the
>  file in a separate filesystem (mounted as part of fail-over) rather
>  than in /var.
>  This can(?) be achieved using a symlink, but rpm likes to remove
>  symlinks to non-existent locations.
> 
>  With NFSv3 the equivalent is the state files maintained by statd, and
>  these can be relocated by passing the -P option to rpc.statd.
>  How does one do a similar thing for NFSv4???
> 
> 

Ahh, I added that option mostly for when I was testing it. I did a lot
of the earlier testing running it by hand, and --storagedir let me use a
different directory for the db. I did have a vague idea that we might
use it in the situation you describe, but I never wired that up as I
didn't have a real need for it.

We could add a new module parm that would set that option when the
kernel does its callout, or allow passing the storagedir by environment
variable.

What would make the most sense from a usability standpoint?

-- 
Jeff Layton <jlayton@redhat.com>
