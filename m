Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38630
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750777Ab1ITPkM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 11:40:12 -0400
Date: Tue, 20 Sep 2011 11:40:11 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] statd: Decouple statd's state directory from the NFS
 state directory
Message-ID: <20110920154011.GA6959@infradead.org>
References: <1316531020-25071-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316531020-25071-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 20, 2011 at 11:03:40AM -0400, Steve Dickson wrote:
> To allow greater flexibility to where statd's state is kept,
> statd's state path can now be decoupled from the normal
> NFS state directory.
> 
> In configure.ac, the NSM_STATD_PATH definition will now define
> the path to where the state information is kept. The default
> value, /var/lib/nfs, can be redefined with the --with-statdpath
> flag.

What is thje rationale for this?  And who would want to move it at
compile time, not at run time?
