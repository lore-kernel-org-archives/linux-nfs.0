Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56245 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbFEAus (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 20:50:48 -0400
Date: Fri, 5 Jun 2015 01:50:43 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>,
        linux-nfs@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>,
        "SHUANG.QIU" <shuang.qiu@oracle.com>
Subject: Re: nfsd: EACCES vs EPERM on utime()/utimes() calls
Message-ID: <20150605005043.GR7232@ZenIV.linux.org.uk>
References: <556C73AE.4090900@oracle.com>
 <20150601212317.GF26972@fieldses.org>
 <556DD52D.5040405@oracle.com>
 <557047E2.10804@gmail.com>
 <20150604202725.GE5209@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150604202725.GE5209@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 04, 2015 at 04:27:25PM -0400, J. Bruce Fields wrote:

> I wonder if we could instead skip the fh_verify's inode_permission call
> entirely?  Most callers of fh_verify don't need the inode_permission
> call at all as far as I can tell, because the following vfs operation
> does permission checking already.

In case of notify_change() we only pass a dentry, so anything mount-dependent
must be done in callers...  Actually, I wonder how does tomoyo and its ilk
interact with nfsd?
