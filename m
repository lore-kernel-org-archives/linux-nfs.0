Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:55831 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758790Ab1IIMAy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:00:54 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: David Howells <dhowells@redhat.com>
Cc: dhowells@redhat.com, agruen@kernel.org, bfields@fieldses.org,
        akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 08/26] vfs: Add new file and directory create permission flags
In-Reply-To: <22786.1315562578@redhat.com>
References: <1315243548-18664-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <22786.1315562578@redhat.com>
Date: Fri, 09 Sep 2011 17:29:41 +0530
Message-ID: <87aaae3p02.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 09 Sep 2011 11:02:58 +0100, David Howells <dhowells@redhat.com> wrote:
> Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > -static inline int may_create(struct inode *dir, struct dentry *child)
> > +static inline int may_create(struct inode *dir, struct dentry *child, int isdir)
> 
> Would it make sense to pass the proposed mode_t instead?  That way you can
> check for symlinks and other file types too if necessary later.
> 

How about making that change when we need to check for those file types
?. Currently we need to check only if it is a directory or not, and most
of the callers and simply use 1, 0, converting it to mode_t would mean
we build proper mode values there.

-aneesh
