From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: atimes not updated over NFS
Date: Mon, 14 Jan 2008 09:34:35 +0100
Message-ID: <20080114083435.GA24215@janus>
References: <20080109101313.GG9212@aym.net2.nerim.net> <1199892437.11141.2.camel@heimdal.trondhjem.org> <20080109223748.GH9212@aym.net2.nerim.net> <1199920996.7638.3.camel@heimdal.trondhjem.org> <20080109235153.GI9212@aym.net2.nerim.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:34136 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753132AbYANIeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2008 03:34:37 -0500
In-Reply-To: <20080109235153.GI9212-956IwFboN44acnK+F/IuxqxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 10, 2008 at 12:51:53AM +0100, Andre Majorel wrote:
> On 2008-01-09 18:23 -0500, Trond Myklebust wrote:
> > On Wed, 2008-01-09 at 23:37 +0100, Andre Majorel wrote:
> >
> > > I'll take your word for it. However, let me assure you that atimes
> > > somehow used to work over NFS, even for files small enough to fit
> > > in the cache. Had they been broken, I would have known. I use Mutt.
> > 
> > How would the server know to update the atime? If the file is in cache
> > we don't READ.
> 
> You tell me. All I can tell you is that Mutt used to work so
> atimes were updated one way or another.

I think 2.6.22 introduced this regression. On 2.6.22.10, reading a file
on NFS does not affect atime according to stat(), not on the client and
not on the server. This breaks several programs.

Commands to reproduce this problem on the client:

	dd </dev/zero >testfile count=1
	ls -l --time=atime --full-time testfile
	sleep 2
	wc testfile
	ls -l --time=atime --full-time testfile
		(same atime, not good)


-- 
Frank
