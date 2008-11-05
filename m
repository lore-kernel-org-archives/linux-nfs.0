From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 8/8] NLM: allow lockd requests from an unprivileged port
Date: Wed, 05 Nov 2008 16:34:32 -0500
Message-ID: <1225920872.16857.47.camel@heimdal.trondhjem.org>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net>
	 <20081105202542.14469.35584.stgit@ingres.1015granger.net>
	 <1225917994.16857.42.camel@heimdal.trondhjem.org>
	 <70C4B893-100A-4047-8038-C401DA44B439@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21622 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbYKEVfa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 16:35:30 -0500
In-Reply-To: <70C4B893-100A-4047-8038-C401DA44B439@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-11-05 at 16:25 -0500, Chuck Lever wrote:
> On Nov 5, 2008, at 3:46 PM, Trond Myklebust wrote:
> > On Wed, 2008-11-05 at 15:25 -0500, Chuck Lever wrote:
> >> If the admin has specified the "noresvport" option for an NFS mount
> >> point, the kernel's NFS client uses an unprivileged source port for
> >> the main NFS transport.  The kernel's lockd client should use an
> >> unprivileged port in this case as well.
> >>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >
> > error: patch failed: fs/lockd/host.c:44
> > error: fs/lockd/host.c: patch does not apply
> 
> I mentioned that in the cover letter.  It's another case where patches  
> I've sent to you depend on patches that Bruce is taking.

OK. Dropping that patch...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
