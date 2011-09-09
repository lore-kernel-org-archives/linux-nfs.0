Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757532Ab1IIKMi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 06:12:38 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self permission flags
Date: Fri, 09 Sep 2011 11:12:06 +0100
Message-ID: <22928.1315563126@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:

> +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> +	    !inode_permission(inode, MAY_DELETE_SELF))
> +		error = 0;

This might be easier to follow if you used == 0 rather than !.  The problem
with ! is that it looks like:

	not_have inode_permission.

I guess this is just one of the fun consequences of having 0 (false) meaning
okay.

David
