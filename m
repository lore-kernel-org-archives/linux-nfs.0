Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbcEINkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 May 2016 09:40:11 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20160508083543.GA14316@infradead.org>
References: <20160508083543.GA14316@infradead.org> <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 09 May 2016 14:40:08 +0100
Message-ID: <1852.1462801208@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> And please prepare a man page to document this system call properly.

I intend to - but when it's stabilised sufficiently to warrant inclusion.

David
