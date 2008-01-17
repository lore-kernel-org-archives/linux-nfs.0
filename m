From: David Howells <dhowells@redhat.com>
Subject: Re: [NFS] [PATCH 06b/26] Security: Make NFSD work with detached
	security
Date: Thu, 17 Jan 2008 23:02:06 +0000
Message-ID: <29216.1200610926@redhat.com>
References: <28942.1200610127@redhat.com> <20080117204804.GC6416@fieldses.org>
	<20080115234724.22183.9603.stgit@warthog.procyon.org.uk>
	<20080115234652.22183.24850.stgit@warthog.procyon.org.uk>
	<20849.1200590240@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de,
	Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org,
	dhowells@redhat.com, linux-security-module@vger.kernel.org,
	nfs@lists.sourceforge.net, selinux@tycho.nsa.gov,
	casey@schaufler-ca.com, sds@tycho.nsa.gov
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59842 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbYAQXCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 18:02:42 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JFdkr-0005Ic-3E
	for linux-nfs@vger.kernel.org; Fri, 18 Jan 2008 10:02:38 +1100
In-Reply-To: <28942.1200610127@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > Just curious--why?  Are get_kernel_security(), etc., particularly
> > expensive?
> 
> It involves a kmalloc().  That means an extra possibility for an error.  Plus
> it may allow you to cache the result of checking whether, say, SELinux
> security labels are allowed to be set when passed over NFS (if such is
> possible).

Apart from that, though, no, it's not particularly expensive.

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

