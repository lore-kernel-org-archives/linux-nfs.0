Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51875 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757745Ab2CGNPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 08:15:01 -0500
Date: Wed, 7 Mar 2012 08:14:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd41: implement NFS4_SHARE_WANT_NO_DELEG,
 NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg
Message-ID: <20120307131458.GD30323@fieldses.org>
References: <4F3D4F1F.6080502@tonian.com>
 <1329418637-23925-1-git-send-email-bhalevy@tonian.com>
 <20120217221411.GA3627@fieldses.org>
 <4F3F5B30.3000501@tonian.com>
 <20120218144103.GA7997@fieldses.org>
 <4F426B07.1080804@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F426B07.1080804@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 20, 2012 at 07:47:19AM -0800, Benny Halevy wrote:
> On 2012-02-18 06:41, J. Bruce Fields wrote:
> > On Sat, Feb 18, 2012 at 10:02:56AM +0200, Benny Halevy wrote:
> >> I'm sending two additional patches that refactor these two helpers and add
> >> some documentation to the commit message.
> >>
> >> I think it might be helpful to keep them separated but let me know otherwise
> >> and I'll send a squashed patch instead.
> > 
> > Either way's fine.  What I've got so far is pushed out to
> > 
> > 	git://linux-nfs.org/~bfields/linux.git for-3.4
> 
> Good. So the missing patches are:
> http://marc.info/?l=linux-nfs&m=132941866004294&w=2
> http://marc.info/?l=linux-nfs&m=132955306211255&w=2
> http://marc.info/?l=linux-nfs&m=132955306211256&w=2

Sorry for the delay.  I've committed and pushed out everything I have
from you (to git://linux-nfs.org/~bfields/linux.git for-3.4).  Let me
know if I've overlooked anything.

--b.
