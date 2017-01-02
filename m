Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35034 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750981AbdABIkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Jan 2017 03:40:08 -0500
Date: Mon, 2 Jan 2017 09:40:05 +0100
From: Christoph Hellwig <hch@lst.de>
To: Bruce James Fields <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [nfsv4] RFC 7530: Filehandle of opened file after the REMOVE
Message-ID: <20170102084005.GA3471@lst.de>
References: <CAABAsM7v6y0bsb0jKzfvobkUjniTLhM3uv8FYjo07HcLD2004w@mail.gmail.com> <20161227144414.GA32002@fieldses.org> <CADaq8jck14SKL6Ua9QxbqPyX1=1aaA7+76wv-__EWFvh7ZcEJA@mail.gmail.com> <C496AE44-0F27-4B66-A1F6-A76AEAFD7A90@gmail.com> <20161229024703.GA21325@fieldses.org> <20161229074830.GA3002@lst.de> <20161229205426.GA389@fieldses.org> <20161230083530.GA26413@lst.de> <20170101135817.GA18418@lst.de> <20170101221025.GA7216@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170101221025.GA7216@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 01, 2017 at 05:10:25PM -0500, Bruce James Fields wrote:
> How do we handle clean shutdown, though?  At a minimum a server admin
> needs to be able to e.g. take down the server for an OS upgrade.

That's going to be a nightmare to implement unfortunately.
