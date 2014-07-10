Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49316 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262AbaGJTnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 15:43:50 -0400
Date: Thu, 10 Jul 2014 15:43:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: swise@ogc.net, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 2/2] svcrdma: Remove extra writeargs sanity check for
 NFSv2/3
Message-ID: <20140710194349.GD26561@fieldses.org>
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
 <20140710174435.3734.69638.stgit@klimt.1015granger.net>
 <20140710181944.GB26561@fieldses.org>
 <3BA364F8-E5ED-45A1-8662-E5F91AA7AF0A@oracle.com>
 <20140710184948.GC26561@fieldses.org>
 <B89AB7AC-32E1-4944-9287-73958A569A8E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <B89AB7AC-32E1-4944-9287-73958A569A8E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 03:07:34PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> On Jul 10, 2014, at 2:49 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Jul 10, 2014 at 02:24:57PM -0400, Chuck Lever wrote:
> >> 
> >> On Jul 10, 2014, at 2:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >>> On Thu, Jul 10, 2014 at 01:44:35PM -0400, Chuck Lever wrote:
> >>>> The server should comply with RFC 5667,
> >>> 
> >>> Where's the relevant language?  (I took a quick look but didn't see it.)
> >> 
> >> Sorry, I listed the wrong RFC when I wrote the description of bug 246.
> >> It’s actually RFC 5666, section 3.7.
> > 
> > Thanks.
> > 
> >>> So I think you just want to drop the round-up of len, not the whole
> >>> check.
> >> 
> >> I’ll try that, thanks!
> 
> Works-as-expected.
> 
> > Actually, I'd really rather this get fixed up in the rpc layer.  The
> > padding is really required for correct xdr.
> 
> How so?

Well, to be spec-lawyerly, rfc 1832 3.9 defines opaque data as including
the zero-padding; a sequence of bytes isn't legal xdr if it just ends
early.

> All of NFSv4 and all other NFSv3 operations work as expected
> without that padding present. There doesn’t seem to be any operational
> dependency on the presence of padding. Help?

I can believe that the code deals with it now, I just wonder if this
check may not be the only case where someone writing xdr code expects
total length to be a multiple of four.

The drc code also depends on the length being right, see
nfsd_cache_csum.  I don't know whether that will cause a practical
problem in this case.

(What about the krb5i case?)

> > The fact that RDMA doesn't
> > require those zeroes to be literally transmitted across the network
> > sounds like a transport-level detail that should be hidden from the xdr
> > code.
> 
> The best I can think of is adding a false page array entry to the
> xdr_buf if the last incoming page is short by a few bytes.

The padding just gets added to the end of whichever page the write ended
on, and you only use another page if you run out of space, right?

I don't know, if that's a huge pain then I guess we can live with this.

--b.
