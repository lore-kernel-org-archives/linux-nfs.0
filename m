Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:41448 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab1AENk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 08:40:29 -0500
Date: Wed, 5 Jan 2011 15:40:28 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Message-ID: <20110105134028.GA9620@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <20110105114155.GN19804@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110105114155.GN19804@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 11:41:55AM +0000, Al Viro wrote:
> On Wed, Dec 29, 2010 at 03:14:18PM +0200, Kirill A. Shutemov wrote:
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> 
> Won't that make sunrpc impossible to rmmod once you've got it in?

Oops.. Nice catch.

I'll fix it by relacing remaing references of init_rpc_pipefs with
get_rpc_pipefs(NULL) at the end of the patchset and move init_rpc_pipefs
mounting to get_rpc_pipefs(). So, we will have temporary regression in the
middle of the patchset, but I think it's not a problem.

-- 
 Kirill A. Shutemov
