Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50740 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751597AbeCXCks (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Mar 2018 22:40:48 -0400
Date: Fri, 23 Mar 2018 22:40:47 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 1/2] NFSD: Clean up write argument XDR decoders
Message-ID: <20180324024047.GW4288@fieldses.org>
References: <20180319184647.10100.25736.stgit@klimt.1015granger.net>
 <20180319185648.10100.94060.stgit@klimt.1015granger.net>
 <20180323213253.GV4288@fieldses.org>
 <4061A951-7FA1-4E85-9D04-3AB5F20A4A7B@oracle.com>
 <ABCD8B94-C1F9-475A-AF45-53DC3EAEFB41@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ABCD8B94-C1F9-475A-AF45-53DC3EAEFB41@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 23, 2018 at 06:37:51PM -0400, Chuck Lever wrote:
> 
> 
> > On Mar 23, 2018, at 5:55 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > 
> > 
> >> On Mar 23, 2018, at 5:32 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> If I understand correctly, in the v4 case you change the way the page
> >> data is passed by using rq_arg.pages instead of a list of pages for each
> >> write.
> >> 
> >> I don't think that handles the case of compounds with multiple writes.
> >> 
> >> If all the writes are contained in a page, then you may be OK, since the
> >> wr_head iovec is all the information you need to pass the write data
> >> from the xdr code to the proc code.
> >> 
> >> But if there are multiple larger writes, you also need to know where the
> >> page data is.  You're depending on rq_arg.pages for that, but there's
> >> only one of those per compound.
> > 
> > I thought we were going to handle that case by chaining xdr_bufs--
> > one per NFSv4 WRITE operation. There has to be some structured way
> > to pass distinct write payloads up to the NFS server, otherwise
> > direct placement is impossible.
> 
> Thinking on this a little more, I think you are saying the new shared
> decoder is adequate for NFSv2 and NFSv3, but not for NFSv4.

Yes, it would be a regression in the v4 case, but not in the v2 or v3
cases.

> Would you
> accept a patch that kept the NFSv2 and NFSv3 parts of this patch, but
> dropped the NFSv4-related hunks?
> 
> Likewise for the symlink decoder patch?

I'll have to take another look, but, could be.

> And we can still use a transport call-out in the XDR decoders, just as
> we have discussed. (I think I've misremembered our discussion about
> chaining xdr_bufs).

Maybe chaining xdr bufs would make sense, I haven't thought about it.

But we currently handle multiple IOs per compound without chaining xdr
bufs.

--b.
