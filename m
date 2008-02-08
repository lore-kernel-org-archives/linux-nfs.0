From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 06/11] NFSD: Remove NFSv4 dependency on NFSv3
Date: Fri, 8 Feb 2008 22:50:54 +0100
Message-ID: <20080208215054.GB541@uranus.ravnborg.org>
References: <20080208175208.16261.74626.stgit@manray.1015granger.net> <20080208202033.GD31984@uranus.ravnborg.org> <42BB19FA-AF43-4BF6-AF32-EF31A17A41B4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:39935 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbYBHVus (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 16:50:48 -0500
In-Reply-To: <42BB19FA-AF43-4BF6-AF32-EF31A17A41B4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 08, 2008 at 04:08:42PM -0500, Chuck Lever wrote:
> On Feb 8, 2008, at 3:20 PM, Sam Ravnborg wrote:
> >On Fri, Feb 08, 2008 at 12:52:08PM -0500, Chuck Lever wrote:
> >>Clean up: Because NFSD_V4 "depends on" NFSD_V3, it appears as a  
> >>child of
> >>the NFSD_V3 menu entry, and is not visible if NFSD_V3 is unselected.
> >>
> >>Replace the dependency on NFSD_V3 with a "select NFSD_V3".  This  
> >>makes
> >>NFSD_V4 look and work just like NFS_V3, while ensuring that  
> >>NFSD_V3 is
> >>enabled if NFSD_V4 is.
> >>
> >>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>---
> >>
> >> fs/Kconfig |    3 ++-
> >> 1 files changed, 2 insertions(+), 1 deletions(-)
> >>
> >>diff --git a/fs/Kconfig b/fs/Kconfig
> >>index 9ad62a9..4c16789 100644
> >>--- a/fs/Kconfig
> >>+++ b/fs/Kconfig
> >>@@ -1723,7 +1723,8 @@ config NFSD_V3_ACL
> >>
> >> config NFSD_V4
> >> 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
> >>-	depends on NFSD && NFSD_V3 && EXPERIMENTAL
> >>+	depends on NFSD && EXPERIMENTAL
> >>+	select NFSD_V3
> >> 	select RPCSEC_GSS_KRB5
> >> 	help
> >> 	  This option enables support in your system's NFS server for
> >
> >This use of select is questionable. In general it is bad to select
> >a symbol with dependencies.
> >In this case the dependencies of NFSD_V3 are duplicated for NFSD_V4
> >so we will not se erratic configurations but do you remember to
> >update NFSD_V4 when you add a depends on NFSD_V3?
> >
> >But I see no other clean way to do it rithg now.
> 
> This patch is entirely optional, and I can just drop it for now.

Keep it. My comment was more to say we have things to address in kconfig.
This is abuse in the acceptable range.

	Sam
