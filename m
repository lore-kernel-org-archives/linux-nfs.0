From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [git-KezNCC8cqm5ZN1qrTdtDg5Vzexx5G7lz@public.gmane.org: all 5e2e7721... NFS: fix
	nfs_parse_ip_address() corner case results]
Date: Mon, 13 Oct 2008 16:17:02 -0400
Message-ID: <20081013201702.GB31876@fieldses.org>
References: <20081013191507.GA31876@fieldses.org> <1223927672.15530.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55356 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbYJMURF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2008 16:17:05 -0400
In-Reply-To: <1223927672.15530.5.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 13, 2008 at 03:54:32PM -0400, Trond Myklebust wrote:
> On Mon, 2008-10-13 at 15:15 -0400, J. Bruce Fields wrote:
> > I'm seeing cthon failures on your linux-mm branch again, this time
> > intermittent--and maybe only on v4?  I haven't tried to look any closer
> > yet.
> > 
> > --b.
> 
> I don't appear to be able to reproduce that. Do you have a tcpdump?

I only see it once in every 10 runs or so.  I'll see what I can get....

--b.
