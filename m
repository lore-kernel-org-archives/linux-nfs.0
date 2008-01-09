From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: atimes not updated over NFS
Date: Wed, 09 Jan 2008 18:23:16 -0500
Message-ID: <1199920996.7638.3.camel@heimdal.trondhjem.org>
References: <20080109101313.GG9212@aym.net2.nerim.net>
	 <1199892437.11141.2.camel@heimdal.trondhjem.org>
	 <20080109223748.GH9212@aym.net2.nerim.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:36610 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbYAIXXU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 18:23:20 -0500
In-Reply-To: <20080109223748.GH9212-956IwFboN44acnK+F/IuxqxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-09 at 23:37 +0100, Andre Majorel wrote:
> I'll take your word for it. However, let me assure you that atimes
> somehow used to work over NFS, even for files small enough to fit
> in the cache. Had they been broken, I would have known. I use Mutt.

How would the server know to update the atime? If the file is in cache
we don't READ.

Trond

