Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45392 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822Ab1DRUHr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2011 16:07:47 -0400
Date: Mon, 18 Apr 2011 16:07:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: make sure nfs server process OPEN with
 EXCLUSIVE4_1 correcttly
Message-ID: <20110418200745.GA1162@fieldses.org>
References: <4D9C2CB2.7000101@cn.fujitsu.com>
 <20110407195005.GC11806@fieldses.org>
 <4D9EDC05.2080809@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D9EDC05.2080809@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Apr 08, 2011 at 05:57:25PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields :
> > On Wed, Apr 06, 2011 at 05:04:50PM +0800, Mi Jinlong wrote:
> >> At the recent kernel(2.6.39-rc1),
> > 
> > (But this is not a regression, right?  This has been a problem all
> > along.)
> 
>   Yes, I think it's just a problem.
> 
> > 
> >> NFS server can't process OPEN with EXCLUSIVE4_1,
> >> because NFS server call nfsd_create_v3 to create file instead implement a separate
> >> one. But nfsd_create_v3 can't process createmode is EXCLUSIVE4_1.
> > 
> > Is our handling of the attributes correct in this case?  (See e.g. the
> > op_bmval[1] assignment a few lines down.)
> 
>   There is no problem of the p_bmval[1] assignment a few lines down.
>   According to rfc5661 18.16.3, EXCLUSIVE4_1 supports the setting of
>   attributes at file creation, we don't need to set p_bmval[1] assignment
>   as EXCLUSIVE.
> 
>   I think we should have a fix at nfsd_create_v3(), not at do_open_lookup().
>   Please ignore the old patch, a new one is as following.
> 
> --
> thanks,
> Mi Jinlong
> 
> =============================================================================
> >From 7adf0213b525c02761022c7fee60f52012d32a9a Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Mon, 4 Apr 2011 00:49:19 +0800
> Subject: [PATCH] nfsd41: make sure nfs server process OPEN with EXCLUSIVE4_1 correcttly
> 
> NFS server can't process OPEN with EXCLUSIVE4_1, because NFS server call 
> nfsd_create_v3 to create file instead implement a separate one. 
> But nfsd_create_v3 can't process createmode is EXCLUSIVE4_1.
> 
> This patch rename nfsd_create_v3() to do_nfsd_create(),

Good idea.

> -	if (createmode == NFS3_CREATE_EXCLUSIVE) {
> +	if (createmode & NFS3_CREATE_EXCLUSIVE) {

Using & NFS3_CREATE_EXCLUSIVE is a little too clever; I'd rather just
write out (createmode == NFS3_CREATE_EXCLUSIVE) || (createmode ==
NFS4_CREATE_EXCLUSIVE4_1).  If that's too cumbersome, define a static
inline helper nfsd_create_is_exclusive(createmode) in a header
somewhere.

> +#ifdef CONFIG_NFSD_V4
> +		case NFS4_CREATE_EXCLUSIVE4_1:
> +#endif

And I'd rather avoid these ifdef's in the main part of the code.  Could
we move the definition of NFS4_CREATE_EXCLUSIVE4_1 someplace common
instead?

--b.
