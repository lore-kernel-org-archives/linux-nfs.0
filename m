From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] 3-word attributes encoding
Date: Wed, 1 Apr 2009 12:19:44 -0400
Message-ID: <20090401161944.GE5018@fieldses.org>
References: <49D0D931.2060808@panasas.com> <20090331014439.GA7273@fieldses.org> <49D26298.6070507@panasas.com> <20090331194215.GE20756@fieldses.org> <49D27672.9060007@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34451 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756057AbZDAQTs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 12:19:48 -0400
In-Reply-To: <49D27672.9060007@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2009 at 11:00:50PM +0300, Benny Halevy wrote:
> On Mar. 31, 2009, 22:42 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Tue, Mar 31, 2009 at 09:36:08PM +0300, Benny Halevy wrote:
> >> On Mar. 31, 2009, 4:44 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>> On Mon, Mar 30, 2009 at 05:37:37PM +0300, Benny Halevy wrote:
> >>>> Bruce,
> >>>>
> >>>> As I mentioned in a reply to Trond,
> >>>> "nfsd41: support for 3-word long attribute bitmask"
> >>>> changes the server fattr encoding logic so it may send
> >>>> back a bitmap of length 1, even if the client sent a
> >>>> bitmap of length 2, if the second word of the bitmap
> >>>> is zero.  Although I think this a valid implementation
> >>>> and other servers may do the same, it seems sub-optimal
> >>>> for the client's decoding of acl of fs_locations.
> >>> "suboptimal" means it does some extra memcpy'ing?
> >> Yes, I believe so.
> >>
> >>>> It's pretty easy to revert to the old behavior on the server
> >>>> by always returning at least two bitmap words, or, if we
> >>>> keep the bitmap length, not just the val, in nfsd4_decode_bitmap
> >>>> we can return a bitmap of the same length in the reply.
> >>> Odd thing to have to do, but OK. --b.  
> >> What would you prefer to do?
> >> Revert to old behavior by returning at least two bitmap words
> >> or use the args bitmap length for encoding the res?
> > 
> > Whichever requires the least code?  I don't know.
> 
> The former seems simpler to code.
> 
> > 
> > If the client really needs this, then it needs to be agreed on by more
> > than just the linux server.  It's unfortunate if making this arbitrary
> > undocumented choice of result encoding makes a significant difference to
> > the client's performance.
> 
> I think that currently it affects only getacl and I have no measurements
> of to what extent the effect of performance is.

I'd rather just not worry about it.  If it turns out to be a problem
then we can try to figure out a less fragile solution.

--b.
