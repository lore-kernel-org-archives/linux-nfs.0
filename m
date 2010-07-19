Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933745Ab0GSOK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 10:10:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100718085048.GC27794@infradead.org>
References: <20100718085048.GC27794@infradead.org> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021723.5544.85730.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 12/18] xstat: Add a dentry op to handle automounting rather than abusing follow_link() [ver #6]
Date: Mon, 19 Jul 2010 15:10:48 +0100
Message-ID: <8474.1279548648@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Christoph Hellwig <hch@infradead.org> wrote:

> Moving this out of ->follow_link is a good idea, but please submit this
> as a separate patch series, as it has very little to do with stat().

Except that I want to use it to create a new AT flag for xstat() (and also
fstatat()), but fair enough.

David
