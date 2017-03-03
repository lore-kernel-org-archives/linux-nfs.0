Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:36152 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdCCTZv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 14:25:51 -0500
Received: by mail-ua0-f173.google.com with SMTP id 72so126577605uaf.3
        for <linux-nfs@vger.kernel.org>; Fri, 03 Mar 2017 11:25:10 -0800 (PST)
Message-ID: <1488569105.2997.1.camel@poochiereds.net>
Subject: Re: Confused by pnfs LAYOUTRETURN - seeking clarity.
From: Jeff Layton <jlayton@poochiereds.net>
To: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org
Date: Fri, 03 Mar 2017 14:25:05 -0500
In-Reply-To: <87shmvnzh7.fsf@notabene.neil.brown.name>
References: <87shmvnzh7.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-03-03 at 08:24 +1100, NeilBrown wrote:
> I've been trying to understand how LAYOUTRETURN is used in pNFS,
> primarily because our SLE12-SP1 kernel (based on 3.12) appears
> to have a very different opinion than some Netapp filers.
> 
> My reading of RFC-5661 suggests that the client needs to call
> LAYOUTRETURN for every layout that it received from the server.  A
> single LAYOUTRETURN can cover a whole file or a whole filesystem, so it
> doesn't need to be 1-for-1, but there is no implicit return.
> 
> However RFC-5663 contains the text
> 
>    A LAYOUTRETURN operation represents an explicit release of resources
>    by the client, usually done for the purpose of avoiding unnecessary
>    CB_LAYOUTRECALL operations in the future.
> 
> This seems to imply that LAYOUTRETURN is only an optimisation.  If you
> don't want to avoid CB_LAYOUTRECALL, there is not much call for
> LAYOUTRETURN.  It seems to suggest (without explicitly saying) that the
> CB_LAYOUTRECALL will effect the return of a layout without the client
> explicitly sending LAYOUTRETURN in response.  RFC-5661 says LAYOUTRETURN
> does need to be sent in response.
> 
> The code in 3.12 doesn't send LAYOUTRETURN in response to
> CB_LAYOUTRECALL, nor does it send LAYOUTRETURN when it closes a file
> marked as "return layouts on close".  The one place I have seen evidence
> of it returning layouts is when a file is unlinked, though I think there
> are others (chmod, IO error).
> 
> The current upstream code seems to call LAYOUTRETURN more correctly, but
> it is hard to be sure because I couldn't find a commit which acknowledged
> the specific problem and corrected it - just commits that claim to be
> making improvements and avoiding races and things like that.
> 
> Questions:
>  - Am I correct that all layouts need to be explicitly returned by the
>    client, and so the text from RFC-5663 is misleading?
> 

There is one special case...

When the server does a CB_LAYOUTRECALL, the client can reply with
NFS4ERR_NOMATCHING_LAYOUT if it's not actively using the layout at the
time. With that, the client isn't expected to do a LAYOUTRETURN.

Any other status on the CB_LAYOUTRECALL however does require a
LAYOUTRETURN.

>  - If so, what is the earliest kernel that is believed to correctly
>    return layouts in response to CB_LAYOUTRECALL, or a 'roc' file being
>    closed?
> 
> I was advised that Netapp are considering a change (netapp issue
> 955835):
>   An enhancement will be added in future versions of Ontap to clear out
>   the corresponding layout states after a file has been closed in the
>   event the client does not return them.
> 
> This sounds like a mistake, unless "clear out" means "send
> CB_LAYOUTRECALL for".  Should we advice Netapp against this?
> 
> Thanks,
> NeilBrown
> 

