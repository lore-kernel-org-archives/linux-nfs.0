From: David Howells <dhowells@redhat.com>
Subject: Re: [NFS] [PATCH 06b/26] Security: Make NFSD work with detached
	security
Date: Thu, 17 Jan 2008 22:48:47 +0000
Message-ID: <28942.1200610127__24482.6826303781$1200610997$gmane$org@redhat.com>
References: <20080117204804.GC6416@fieldses.org>
	<20080115234724.22183.9603.stgit@warthog.procyon.org.uk>
	<20080115234652.22183.24850.stgit@warthog.procyon.org.uk>
	<20849.1200590240@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, Trond.Myklebust@netapp.com,
	linux-kernel@vger.kernel.org, dhowells@redhat.com,
	linux-security-module@vger.kernel.org, nfs@lists.sourceforge.net,
	selinux@tycho.nsa.gov, casey@schaufler-ca.com, sds@tycho.nsa.gov
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59841 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbYAQXCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 18:02:38 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JFdkm-0005ID-9w
	for linux-nfs@vger.kernel.org; Fri, 18 Jan 2008 10:02:32 +1100
In-Reply-To: <20080117204804.GC6416@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> Just curious--why?  Are get_kernel_security(), etc., particularly
> expensive?

It involves a kmalloc().  That means an extra possibility for an error.  Plus
it may allow you to cache the result of checking whether, say, SELinux
security labels are allowed to be set when passed over NFS (if such is
possible).

David

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

