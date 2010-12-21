Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:42806 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab0LUXcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Dec 2010 18:32:16 -0500
Date: Wed, 22 Dec 2010 01:32:15 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>, Pavel Emelyanov <xemul@parallels.com>,
        linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 00/12] make rpc_pipefs be mountable multiple times
Message-ID: <20101221233215.GC7092@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
 <20101220144644.GC20643@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101220144644.GC20643@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 20, 2010 at 09:46:44AM -0500, J. Bruce Fields wrote:
> On Mon, Dec 20, 2010 at 01:54:26PM +0200, Kirill A. Shutsemov wrote:
> > From: Kirill A. Shutemov <kirill@shutemov.name>
> > 
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> > Only for client for now.
> > 
> > Only quick sanity check was made. BTW, is there any check list for NFS
> > contributors?
> 
> Nothing formal.
> 
> Chuck may have some nlm patches that conflict; I'm not sure what their
> status is.
> 
> For testing rpc_pipefs, maybe a few mounts (simultaneous mounts might be
> good), possibly over different security flavors, and with some of them
> nfsv4, might be a good idea.

Ok, I'll play with it.

> By the way, was there ever a resolution to Trond's question?:
> 
> 	http://marc.info/?l=linux-nfs&m=128655758712817&w=2
> 
> 	"The keyring upcalls are currently initiated through the same
> 	mechanism as module_request and therefore get started with the
> 	init_nsproxy namespace. We'd really like them to run inside the
> 	same container as the process.  As part of the same problem,
> 	there is the issue of what to do with the dns resolver and
> 	Bryan's new keyring based idmapper code."

I'm not sure that I understand the problem correctly.

Currently, idmap uses dentry taken from client's cl_rpcclient->cl_path
(see nfs_idmap_new()). cl_rpcclient (and cl_path) is initialized with
rpcmount resolved against mount namespace of mount process (see
nfs_create_rpc_client()).
I assume it's correct.

-- 
 Kirill A. Shutemov
