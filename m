Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36156 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643Ab3EMQPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 May 2013 12:15:53 -0400
Date: Mon, 13 May 2013 12:15:51 -0400
To: Oliver Lee <oliver.lee2007@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: recursive ACL inherit
Message-ID: <20130513161551.GD1931@fieldses.org>
References: <CAEBR3EH71A3jbxhEBcBX7_QFzVw6C9SQuer2zwZ+DDYzqOOWBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAEBR3EH71A3jbxhEBcBX7_QFzVw6C9SQuer2zwZ+DDYzqOOWBg@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 13, 2013 at 01:22:22PM +0100, Oliver Lee wrote:
> Hello,
> 
> When using the nfs4_setfacl tool I've found that recursive operations
> fail when using the d or f inheritance flags because nfs4_setfacl
> tries to apply them to files as well as directories, which obviously
> doesn't make sense.
> 
> so
> 
> nfs4_setfacl -R -s A:df:OWNER@:RWX,A:dfg:GROUP@:RWX,A:df:EVERYONE@:RX /directory
> 
> You would expect to allow:
> owner read,write and execute
> group read,write and execute
> others read and execute
> applied to all directories and files under (and including) /directory,
> so that newly created files and directories also have the same
> permissions
> 
> This fails with:
> Failed setxattr operation: Input/output error
> An error occurred during recursive file tree walk.
> 
> When nfs4_setfacl encounters the first file. All directories before
> the first file are changed correctly
> 
> Am I doing something wrong or is this a bug/missing feature?

I agree, that looks like a bug to me.

> Also, the man page for nfs4_acl references nfs4_setacl in its SEE ALSO
> section, presumably this should be nfs4_setfacl?
> Finally, the man page references nfsv4@linux-nfs.org in its CONTACT section

Fixed those two and pushed results to

	git://linux-nfs.org/~bfields/nfs4-acl-tools.git

For anything else: patches against that git tree welcomed.

--b.
