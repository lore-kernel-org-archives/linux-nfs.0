Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48696 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbcFCD26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 23:28:58 -0400
Date: Fri, 3 Jun 2016 04:28:53 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Oleg Drokin <green@linuxhacker.ru>, "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Message-ID: <20160603032853.GK14480@ZenIV.linux.org.uk>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <F0790F28-A8F9-406E-8B1A-F3F3773DA28E@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F0790F28-A8F9-406E-8B1A-F3F3773DA28E@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 03, 2016 at 12:44:51AM +0000, Trond Myklebust wrote:

> That would have to be a really tight race, since the code in _nfs4_open_and_get_state() currently reads:
> 
>                 d_drop(dentry);
>                 alias = d_exact_alias(dentry, state->inode);
>                 if (!alias)
>                         alias = d_splice_alias(igrab(state->inode), dentry);
> 
> IOW: something would have to be acting between the d_drop() and d_splice_alias() above...

How?  dentry is
	* negative (it would better be, or we are _really_ fucked)
	* unhashed

How does whoever's rehashing it stumble across that thing?
