From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [GIT *] fsid/uuid fixes
Date: Wed, 20 Aug 2008 20:34:51 +0100
Message-ID: <1219260891.2988.197.camel@pmac.infradead.org>
References: <1219229787.2988.108.camel@pmac.infradead.org>
	 <20080820192952.GA21226@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48675 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552AbYHTTe4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2008 15:34:56 -0400
In-Reply-To: <20080820192952.GA21226@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-20 at 15:29 -0400, J. Bruce Fields wrote:
> > I wonder if we should use the fsid from statfs() in _preference_ to
> > using libblkid, since 
> 
> ..?

Er, sorry.

Since there doesn't seem to be much point grovelling around in raw block
devices if we already _have_ a perfectly suitable fsid directly from the
kernel, and it leads to complaints such as the one at
http://www.mail-archive.com/linux-nfs@vger.kernel.org/msg01642.html

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



