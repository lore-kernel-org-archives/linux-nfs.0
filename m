Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c11o147.mxlogic.net ([208.65.144.80]:51783 "EHLO
	p02c11o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab1LUWpd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Dec 2011 17:45:33 -0500
From: Peter Staubach <pstaubach@exagrid.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 21 Dec 2011 17:33:23 -0500
Subject: RE: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C22@IT-1874.Isys.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
	<1324499696-10318-5-git-send-email-jlayton@redhat.com>
	<46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
	<20111221163312.3405c1f3@tlielax.poochiereds.net>
	<121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
	<20111221164810.78d600a9@tlielax.poochiereds.net>
	<20111221165922.589101aa@tlielax.poochiereds.net>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C18@IT-1874.Isys.com>
 <20111221172750.638ed046@tlielax.poochiereds.net>
In-Reply-To: <20111221172750.638ed046@tlielax.poochiereds.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I will need to disagree with the assertion regarding XDR and the packed struct.  XDR can handle a versioned struct very neatly.  It can do so just as easily as text string parsing and with greatly reduced overhead.

		Ps


-----Original Message-----
From: Jeff Layton [mailto:jlayton@redhat.com] 
Sent: Wednesday, December 21, 2011 5:28 PM
To: Peter Staubach
Cc: Chuck Lever; bfields@fieldses.org; steved@redhat.com; linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld

On Wed, 21 Dec 2011 17:04:02 -0500
Peter Staubach <pstaubach@exagrid.com> wrote:

> By text based, you don't really mean encoding the binary structure as a string of ascii hex bytes, right?  Bleah.
> 
> I would suggest that XDR encoding seems quite natural to use when passing binary structs around.
> 

No, I was thinking along the lines of encoding the struct fields as key/value pairs in a string:

    "ver=1,cmd=create,clname=0x1a012bd..."

...binary stuff like the nfs_client_id4 would be hex encoded. Integers would be converted to text representations, etc.

I think if we're going to go to the trouble of encoding this stuff at all, it makes sense to do it in as flexible a manner as possible.

Now that I think about it, using XDR has little benefit over the current packed binary struct. If we ever need to rev the format, it'll be just as much of a pain. With key/value pairs, we should be able to ensure that a mismatch between kernel and userspace versions is more easily dealt with.

> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Jeff Layton
> Sent: Wednesday, December 21, 2011 4:59 PM
> To: Jeff Layton
> Cc: Chuck Lever; bfields@fieldses.org; steved@redhat.com; 
> linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to 
> nfsdcld
> 
> On Wed, 21 Dec 2011 16:48:10 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Wed, 21 Dec 2011 16:37:30 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > > 
> > > On Dec 21, 2011, at 4:33 PM, Jeff Layton wrote:
> > > 
> > > > On Wed, 21 Dec 2011 15:45:01 -0500 Chuck Lever 
> > > > <chuck.lever@oracle.com> wrote:
> > > > 
> > > >> 
> > > >> On Dec 21, 2011, at 3:34 PM, Jeff Layton wrote:
> > > >> 
> > > >>> The daemon takes a versioned binary struct. Hopefully this 
> > > >>> should allow us to revise the struct later if it becomes necessary.
> > > >> 
> > > >> This breaks the pattern of using text-based up- and downcalls in NFSD.  I assume this is binary because nfs_client_id4 is a string of opaque bytes?
> > > >> 
> > > > 
> > > > That's the main reason. We could, of course encode that string 
> > > > in hex or something, and decode it on the other end. No one has 
> > > > presented a strong argument for doing it that way as of yet though.
> > > > 
> > > > If anyone feels strongly about that, then it would be helpful to 
> > > > have them pipe up now and state why they do...
> > > 
> > > <pipe>Because binary data structures are difficult to work with 
> > > over time, which is why other NFSD user space interfaces are 
> > > text-based.</pipe>
> > > 
> > > ;-)
> > > 
> > 
> > *sigh* that was the sort of comments I was hoping to get out of the 
> > RFC postings. But ok...
> > 
> > I'll see about respinning the whole thing with either a text-based 
> > or XDR-based upcall/downcall format. That'll take a while, but I'll 
> > see if I can get it in shape in time for 3.3.
> > 
> 
> ...and while we're discussing it. Does anyone have thoughts on which would be better? I'd probably prefer a text-based format. That's more flexible but is also going to be more verbose. I think we're still well under a page with these requests even in text however so I don't really see that as a problem.
> 

--
Jeff Layton <jlayton@redhat.com>
