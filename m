Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49762 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbdAXQZh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 11:25:37 -0500
Date: Tue, 24 Jan 2017 11:25:36 -0500
To: hch <hch@lst.de>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: special case truncates some more
Message-ID: <20170124162536.GA18025@fieldses.org>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
 <1485104060-15209-2-git-send-email-hch@lst.de>
 <1485174116.2786.7.camel@poochiereds.net>
 <20170123123348.GA28102@lst.de>
 <20170123153615.GA32201@lst.de>
 <1485186729.2786.11.camel@poochiereds.net>
 <20170123160559.GA786@lst.de>
 <1485188442.41392.1.camel@primarydata.com>
 <20170123162607.GA21199@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170123162607.GA21199@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2017 at 05:26:07PM +0100, hch wrote:
> On Mon, Jan 23, 2017 at 04:20:45PM +0000, Trond Myklebust wrote:
> > Note that the POSIX spec seems to have changed recently. The current
> > spec appears to state that we should set the mtime and ctime (and
> > change attribute) on success in open(O_TRUNC), truncate() and
> > ftruncate(). In previous incarnations of the spec, truncate() would
> > only set the time if the size was changed:
> 
> Interesting.  But in this case historical Posix and thus Linux behavior
> still takes precedence and we're not suddently going to change behavior.

Makes sense as a general rule, but is it really likely that anyone
depends on ctime/mtime not changing on a non-size-changing truncate()?

--b.
