Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33785 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932241AbbAFR7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 12:59:50 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so31515371pad.13
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 09:59:50 -0800 (PST)
Date: Tue, 6 Jan 2015 09:59:44 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 10/18] nfsd: implement pNFS layout recalls
Message-ID: <20150106175943.GA14225@kitty.kitty>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-11-git-send-email-hch@lst.de>
 <20150106172508.GE12067@fieldses.org>
 <20150106174214.GB16200@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150106174214.GB16200@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 06:42:14PM +0100, Christoph Hellwig wrote:
> > This bothers me a little: cl_addr is just the address that the
> > exchange_id came from.  In theory there's no one-to-one relationship
> > between NFSv4 clients and IP addresses.  Is it likely the iscsi traffic
> > could use a different interface than the MDS traffic?
> > 
> > If this is the best we can do, then maybe this should at least be
> > documented.
> 
> The pNFS block fencing protocol bothers me a lot, it seems like very
> little thought went into that part of the standard.
> 
> I proposed a new SCSI layout type that fixes those issues on the
> NFSv4 WG list, but there's been zero interest in it:
> 
> http://www.ietf.org/mail-archive/web/nfsv4/current/msg13469.html
> 

I don't know if I would say zero interest or normal apathy on the
NFSv4 WG list to replying outside of the IETF meeting venue.

I'd certainly like to see it go forward.
