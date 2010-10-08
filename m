Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759789Ab0JHX6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 19:58:11 -0400
Date: Fri, 8 Oct 2010 19:57:42 -0400
From: Valerie Aurora <vaurora@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@ftp.linux.org.uk, jmoyer@redhat.com, linux-fs@vger.kernel.org,
        autofs@linux.kernel.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 07/17] Make dentry::d_mounted into a more general field for special function dirs
Message-ID: <20101008235741.GF30846@shell>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk> <20100930181531.30939.10438.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100930181531.30939.10438.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 07:15:31PM +0100, David Howells wrote:
> Make the d_mounted field in struct dentry into a more general field for special
> function directories such as mountpoints and autofs substructures.
> 
> d_mounted is renamed d_managed, and that is split into three fields:
> 
>  (*) #define DMANAGED_MOUNTPOINT	0x0fffffff

No matter how hard I try, I always read this as "DAMAGED".  Which I
can't help but imagine subliminally influences the reader's opinion of
the patches.

Of course I am excellent at naming things, see "chunkfs" and
"relatime".  But some ideas for naming various concepts in this patch:

D_MIGHT_MOUNT
D_CHILL_OUT
D_ITS_COMPLICATED

-VAL
