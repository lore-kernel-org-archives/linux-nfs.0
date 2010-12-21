Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38784 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149Ab0LUXna convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Dec 2010 18:43:30 -0500
Subject: Re: [PATCH 00/12] make rpc_pipefs be mountable multiple times
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Kirill A. Shutemov" <kas@openvz.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
In-Reply-To: <20101221233215.GC7092@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
	 <20101220144644.GC20643@fieldses.org> <20101221233215.GC7092@shutemov.name>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Dec 2010 18:43:28 -0500
Message-ID: <1292975008.16674.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-22 at 01:32 +0200, Kirill A. Shutemov wrote:
> On Mon, Dec 20, 2010 at 09:46:44AM -0500, J. Bruce Fields wrote:
> > By the way, was there ever a resolution to Trond's question?:
> > 
> > 	http://marc.info/?l=linux-nfs&m=128655758712817&w=2
> > 
> > 	"The keyring upcalls are currently initiated through the same
> > 	mechanism as module_request and therefore get started with the
> > 	init_nsproxy namespace. We'd really like them to run inside the
> > 	same container as the process.  As part of the same problem,
> > 	there is the issue of what to do with the dns resolver and
> > 	Bryan's new keyring based idmapper code."
> 
> I'm not sure that I understand the problem correctly.
> 
> Currently, idmap uses dentry taken from client's cl_rpcclient->cl_path
> (see nfs_idmap_new()). cl_rpcclient (and cl_path) is initialized with
> rpcmount resolved against mount namespace of mount process (see
> nfs_create_rpc_client()).
> I assume it's correct.

That would be the legacy idmapper mechanism.

Please see CONFIG_NFS_USE_NEW_IDMAPPER, which uses the keyring upcall
mechanism for greater scalability.


Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

