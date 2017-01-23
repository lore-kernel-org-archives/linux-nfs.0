Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:44199 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750713AbdAWRiT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jan 2017 12:38:19 -0500
Date: Mon, 23 Jan 2017 18:38:17 +0100
From: hch <hch@lst.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: hch <hch@lst.de>, "bfields@redhat.com" <bfields@redhat.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: special case truncates some more
Message-ID: <20170123173817.GA22777@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de> <1485104060-15209-2-git-send-email-hch@lst.de> <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de> <20170123153615.GA32201@lst.de> <1485186729.2786.11.camel@poochiereds.net> <20170123160559.GA786@lst.de> <1485188442.41392.1.camel@primarydata.com> <20170123162607.GA21199@lst.de> <1485192333.34422.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1485192333.34422.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2017 at 05:25:34PM +0000, Trond Myklebust wrote:
> In that case the client will be required to continue to need to send
> mtime/ctime in order to ensure that we get the same historical
> semantics w.r.t. ftruncate() vs truncate().
> 
> IOW: It's not a question of the client being lazy about clearing the
> flags. It's a question of enforcing the correct semantics.

No, the NFS spec requires the server to add an implicit mtime
when the size actually changes.  In fact the current code has a comment
pointing to the section:

 * RFC5661, Section 18.30.4:
 *   Changing the size of a file with SETATTR indirectly
 *   changes the time_modify and change attributes.
 *
 * (and similar for the older RFCs)

And yes, I've double checked that in the RFC.
