Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47334 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbKXIPW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 03:15:22 -0500
Date: Tue, 24 Nov 2015 00:15:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: David Howells <dhowells@redhat.com>, arnd@arndb.de,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Message-ID: <20151124081519.GA16147@infradead.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <564F4F4E.8060603@schaufler-ca.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <564F4F4E.8060603@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2015 at 08:50:22AM -0800, Casey Schaufler wrote:
> How about relevant xattrs? SELinux context, ACL, that sort of thing.
> The fact that these are optional should be taken care of by (4).

Those are not simple, fixed size stat data and would make the system
call a giant mess.
