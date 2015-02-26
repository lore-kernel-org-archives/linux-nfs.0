Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932116AbbBZThO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 14:37:14 -0500
Message-ID: <54EF75E3.4050701@RedHat.com>
Date: Thu, 26 Feb 2015 14:37:07 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC nfs-utils] exports.man: improve documentation of 'nohide'
 and 'crossmnt'
References: <20150216122107.4bfd4225@notabene.brown>
In-Reply-To: <20150216122107.4bfd4225@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/15/2015 08:21 PM, NeilBrown wrote:
> 
> 
> - note that 'nohide' is irrelevant for NFSv4
> - note that children on a 'crossmnt' filesystem cannot be unexported
> - note that 'nocrossmnt' is a valid option, but probably not useful.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed!

steved.

> 
> ---
> 
> I wonder if we should add a new option, e.g. "noaccess" so that children
> of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't need to
> know about this.  It would just tell mountd to refuse to export that
> filesystem even if the parent was "crossmnt".
> ??
> 
> NeilBrown
> 
> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 3d974d92a729..88d9fbebe386 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -218,16 +218,46 @@ This option can be very useful in some situations, but it should be
>  used with due care, and only after confirming that the client system
>  copes with the situation effectively.
>  
> -The option can be explicitly disabled with
> +The option can be explicitly disabled for NFSv2 and NFSv3 with
>  .IR hide .
> +
> +This option is not relevant when NFSv4 is use.  NFSv4 never hides
> +subordinate filesystems.  Any filesystem that is exported will be
> +visible where expected when using NFSv4.
>  .TP
> -.IR crossmnt
> +.I crossmnt
>  This option is similar to
>  .I nohide
> -but it makes it possible for clients to move from the filesystem marked
> -with crossmnt to exported filesystems mounted on it.  Thus when a child
> -filesystem "B" is mounted on a parent "A", setting crossmnt on "A" has
> -the same effect as setting "nohide" on B.
> +but it makes it possible for clients to access all filesystems mounted
> +on a filesystem marked with
> +.IR crossmnt .
> +Thus when a child filesystem "B" is mounted on a parent "A", setting
> +crossmnt on "A" has a similar effect to setting "nohide" on B.
> +
> +With
> +.I nohide
> +the child filesystem needs to be explicitly exported.  With
> +.I crossmnt
> +it need not.  If a child of a
> +.I crossmnt
> +file is not explicitly exported, then it will be implicitly exported
> +with the same export options as the parent, except for
> +.IR fsid= .
> +This makes it impossible to
> +.B not
> +export a child of a
> +.I crossmnt
> +filesystem.  If some but not all subordinate filesystems of a parent
> +are to be exported, then they must be explicitly exported and the
> +parent should not have
> +.I crossmnt
> +set.
> +
> +The
> +.I nocrossmnt
> +option can explictly disable
> +.I crossmnt
> +if it was previously set.  This is rarely useful.
>  .TP
>  .IR no_subtree_check
>  This option disables subtree checking, which has mild security
> 
