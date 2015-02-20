Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52577 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197AbbBTQTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2015 11:19:03 -0500
Date: Fri, 20 Feb 2015 08:19:03 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client updates
Message-ID: <20150220161903.GA17874@infradead.org>
References: <1424448985.3641.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1424448985.3641.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 20, 2015 at 08:16:25AM -0800, Trond Myklebust wrote:
>       NFS: struct nfs_commit_info.lock must always point to inode->i_lock

Is there any point in even keeping that lock pointer around then?
