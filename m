Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:37186 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab3BWRl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Feb 2013 12:41:29 -0500
Date: Sat, 23 Feb 2013 17:41:28 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: handle vfs_getattr errors in acl protocol
Message-ID: <20130223174127.GR4503@ZenIV.linux.org.uk>
References: <20130201131537.GC30668@fieldses.org>
 <20130201185721.GP4503@ZenIV.linux.org.uk>
 <20130201201304.GE30668@fieldses.org>
 <20130222214634.GB30856@fieldses.org>
 <20130222221506.GM4503@ZenIV.linux.org.uk>
 <20130222221835.GC30856@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130222221835.GC30856@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 22, 2013 at 05:18:35PM -0500, J. Bruce Fields wrote:

> > FWIW, I'm going to push the first part of VFS queue later tonight...
> 
> OK, I'll wait and see what's in that.

See for-next...

> (And what should I do with the delegation patches?)

Looking through that stuff...
