Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab3JATnv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 15:43:51 -0400
Date: Tue, 1 Oct 2013 15:43:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131001194324.GG16245@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220810-12909-1-git-send-email-bhalevy@primarydata.com>
 <20130929114327.GB25750@infradead.org>
 <52481939.7060405@primarydata.com>
 <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52481B11.2080407@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 29, 2013 at 03:20:33PM +0300, Benny Halevy wrote:
> On 2013-09-29 15:13, Christoph Hellwig wrote:
> > On Sun, Sep 29, 2013 at 03:12:41PM +0300, Benny Halevy wrote:
> >>> Also why would you want a header
> >>> outside fs/nfsd/ ?
> >>
> >> This header contains the file system interface.
> > 
> > Any interface for the filesystem should be part of exportfs.h, not
> > something nfs-specific.
> 
> Makes sense.  Thanks.
> 
> Bruce - are you ok with moving the pnfs interface definitions to
> include/linux/exportfs.h along with struct export_operations?

Fine by me.--b.

> 
> In fact we can actually extend struct export_operations rather
> than adding pnfs_export_operations...
> 
> Benny
> 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
