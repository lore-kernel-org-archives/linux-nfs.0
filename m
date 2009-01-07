From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 16:08:50 -0800
Message-ID: <1231286930.14345.196.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <20090106215831.GE18147@us.ibm.com>
	 <1231281732.4173.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:35199 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbZAGAJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 19:09:05 -0500
In-Reply-To: <1231281732.4173.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 17:42 -0500, Trond Myklebust wrote:
> On Tue, 2009-01-06 at 15:58 -0600, Serge E. Hallyn wrote:
> 
> > So should we use patch 2/4, plus (as someone - was it you? - suggested)
> > using a DEFAULT instead of init_utsname()->nodename when
> > current->utsname() == NULL?
> 
> No. I'm don't think that 2/4 is correct either. Basically, 2/4 is saying
> that the container that first mounts the filesystem 'owns' it. However
> at the same time we know that the lifetime of the filesystem is in no
> way bounded by the lifetime of the container, and that's what gets you
> into trouble with 'umount' in the first place.
>
> IMO, the current code is the most correct approach, in that it assumes
> that the filesystems are owned by the 'init' namespace.

IMHO This seems more incorrect than trying to use a more proximal
namespace.

Cheers,
	-Matt Helsley

