From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Fri, 8 Feb 2008 21:22:19 +0100
Message-ID: <20080208202219.GE31984@uranus.ravnborg.org>
References: <20080208175215.16261.39243.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:40134 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761606AbYBHUWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 15:22:13 -0500
In-Reply-To: <20080208175215.16261.39243.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 08, 2008 at 12:52:15PM -0500, Chuck Lever wrote:
> Recently a reverse dependency was added to fs/Kconfig to ensure that
> PROC_FS was enabled if NFSD_V4 was enabled.
> 
> There is a guideline in Documentation/kbuild/kconfig-language.txt that
> states "In general use select only for non-visible symbols (no prompts
> anywhere) and for symbols with no dependencies."
> 
> A quick grep around other Kconfig files reveals that no entry currently
> uses "select PROC_FS" -- every one uses "depends on".  Thus CONFIG_NFSD_V4
> should use "depends on PROC_FS" as well.
> 
> For SUNRPC_GSS, it's a little more complex.  Other entries can "select"
> SUNRPC_GSS, as it is non-visible.  However, the guideline suggests an
> entry can't "select" it if it has a dependency (such as PROC_FS).
> So, we add forward dependencies on PROC_FS to RPCSEC_GSS_FOO instead.
> 
> XXX: Both CONFIG_NFSV4 and CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5, which is
> visible, which kconfig-language.txt also frowns upon.  The intent was to
> enable at least one GSS mechanism if V4 was enabled.  Perhaps we should
> make SUNRPC_GSS visible, and make the NFSv4 options visible only if
> SUNRPC_GSS is enabled.

This is better than what we had - so OK.
We can revisit when kconfig gets more features added to support
such configurations.

	Sam
