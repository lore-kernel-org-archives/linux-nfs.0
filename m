Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35468 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759547Ab3EORQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 13:16:04 -0400
Date: Wed, 15 May 2013 13:16:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
Message-ID: <20130515171601.GL16811@fieldses.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
 <20130513162528.1942.64673.stgit@seurat.1015granger.net>
 <20130515160424.GK16811@fieldses.org>
 <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 12:23:12PM -0400, Chuck Lever wrote:
> 
> On May 15, 2013, at 12:04 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, May 13, 2013 at 12:25:28PM -0400, Chuck Lever wrote:
> >> Now that commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state
> >> whenever possible" is reverted...
> >> 
> >> NFSv4 server trunking detection was added with commit 05f4c350 "NFS:
> >> Discover NFSv4 server trunking when mounting" in v3.7.  One of the
> >> issues that the reverted commit 4edaa308 tried to address was that
> >> when server trunking detection was added, we broke the ability to
> >> mount krb5 exports when the client has no keytab.
> > 
> > And that happened because we started asking gssd explicitly for a
> > context for a machine principal instead of for uid=0?  Or for some other
> > reason?
> 
> We've asked gssd for a machine credential for SETCLIENTID for a while now, so "some other reason."  I honestly don't know exactly why it stopped working with my change, but someone bisected it to that one.
> 
> But we've always had some issue with the "no keytab" case because we do require a machine credential for SETCLIENTID.  I'm suggesting a fix for the broad class of problems using "sec=krb5?" that arise due to a missing keytab on the client.
> 
> In this case we need the fix sooner rather than later because it stopped working in 3.7.
> 
> > 
> >> We still need to
> >> address that regression.
> >> 
> >> Let's try a narrow approach to re-enabling sec=krb5 mounts without a
> >> local system keytab, and worry about the other issues when we can
> >> plan concomitant user space and kernel changes.
> >> 
> >> When a GSS security flavor is used on a mount, allow the security
> >> flavor for state management to fall back to AUTH_SYS if there is
> >> a problem setting up a GSS context for it.
> > 
> > This brings back the delay in the case gssd isn't running, doesn't it?
> 
> No.  "When a GSS flavor is used" means ONLY when a GSS flavor is used.  We make the minimal assumption that using a GSS flavor for a mount means the administrator either has gssd running or wants to know when it isn't, and can tolerate a delay in that case.

Oh, got it, thanks.--b.
