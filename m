From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Tue, 12 Feb 2008 17:32:35 -0500
Message-ID: <20080212223235.GP18625@fieldses.org>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net> <20080212212325.GM18625@fieldses.org> <1202852836.9228.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42102 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbYBLWcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 17:32:50 -0500
In-Reply-To: <1202852836.9228.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2008 at 04:47:16PM -0500, Trond Myklebust wrote:
> 
> On Tue, 2008-02-12 at 16:23 -0500, J. Bruce Fields wrote:
> > On Mon, Feb 11, 2008 at 05:12:16PM -0500, Chuck Lever wrote:
> > > Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
> > > ensure that PROC_FS was enabled if NFSD_V4 was enabled.
> > > 
> > > There is a guideline in Documentation/kbuild/kconfig-language.txt that
> > > states "In general use select only for non-visible symbols (no prompts
> > > anywhere) and for symbols with no dependencies."
> > > 
> > > A quick grep around other Kconfig files reveals that no entry currently
> > > uses "select PROC_FS" -- every one uses "depends on".  Thus CONFIG_NFSD_V4
> > > should use "depends on PROC_FS" as well.
> > 
> > OK.
> > 
> > > 
> > > For SUNRPC_GSS, it's a little more complex.  Other entries can "select"
> > > SUNRPC_GSS, as it is non-visible.  However, the guideline suggests an
> > > entry can't "select" it if it has a dependency (such as PROC_FS).
> > > So, we add forward dependencies on PROC_FS to RPCSEC_GSS_FOO instead.
> > 
> > This also makes the client dependent on PROC_FS, which it wasn't before.
> > 
> > I assume nobody cares?
> 
> You assume wrongly. Patch NAKed...

Do you have a use case in mind?  (Just curious.)

--b.
