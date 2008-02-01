From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss
	server cases
Date: Fri, 1 Feb 2008 16:01:12 -0500
Message-ID: <20080201210112.GU4798@fieldses.org>
References: <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org> <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com> <20080128214851.GO16785@fieldses.org> <E83AB0F9-B6CB-49CE-B82C-DA450F4ACE9D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:45397 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757487AbYBAVBQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2008 16:01:16 -0500
In-Reply-To: <E83AB0F9-B6CB-49CE-B82C-DA450F4ACE9D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 01, 2008 at 11:40:20AM -0500, Chuck Lever wrote:
> According to Documentation/kbuild/kconfig-language.txt, "select" is OK to 
> use on non-visible options like NFS_ACL_SUPPORT, LOCKD, and SUNRPC, but 
> generally "depends on" is preferred for setting visible options.  
> Apparently "select" doesn't do proper dependency checking, it just forces 
> the value of the named option.
>
> NFS_FS looks correct in this regard.
>
> However, NFSD is probably not correct... for example, instead of "select 
> NFSD_TCP if NFSD_V4" we should probably instead add a "depends on 
> NFSD_TCP" under NFSD_V4.

OK.

> (Alternately, NFSD_TCP could just go away... hint hint).

I guess that would be OK by me, but I'm not volunteering.

> I'll propose some patches to rectify some of this and fix up the out- 
> of-date help texts.

That'd be great, thanks!

--b.
