From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Thu, 2 Aug 2007 12:05:36 -0400
Message-ID: <20070802160536.GF21282@fieldses.org>
References: <46ADDFB2.9070709@inf.ethz.ch>
	<20070731144824.GA15231@fieldses.org>
	<20070802113255.d686894c.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Stefan Walter <stefan.walter@inf.ethz.ch>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGdBD-0004Bj-4k
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:05:39 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGdBF-0005Su-EC
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:05:43 -0700
In-Reply-To: <20070802113255.d686894c.jlayton@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 02, 2007 at 11:32:55AM -0400, Jeff Layton wrote:
> On Tue, 31 Jul 2007 10:48:24 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > That's an interesting problem.  Thanks for the report!
> > 
> > I don't believe that long comma-delimited string actually has any
> > meaning to the kernel--as far as the kernel is concerned, it's just an
> > opaque object that will be passed back to mountd later (along with a
> > path name) to get export options.
> > 
> > So I suppose that string could be replaced by a hash, or maybe even just
> > by the ip address of the particular host--the disadvantage to the latter
> > being that it would require the kernel to keep a separate export for
> > each client address.
> 
> I started having a look at this today. The original patches that I
> proposed to clean up the rmtab a few months ago also eliminated this
> comma-delimited string. Neil had valid objections to it at the time,
> but if we switched to using the IP address as a cache key like Bruce
> describes then doing that becomes more reasonable.
> 
> The only downside I see is the one Bruce points out -- the size of
> the kernel export cache would increase. I don't have a feel for whether
> this is a show stopper, however.

Yeah, there might be some risk of solving that problem at the expense of
people with tons of clients all matching *.example.com.  The actual
export objects are actually pretty small--68 bytes, last I checked?
You'd also need two upcalls to mountd per client (for ip address and
export, as opposed to just ip address).  I don't know what other costs
there might be.

What about the idea of hashing the comma-delimited list and passing
that?  You'd want hash large enough to be collision-free--might as well
use some cryptographic hash, I guess, though it may be mild overkill.
Is there any reason why that wouldn't work?

Could you remind me what problems you were trying to fix with your rmtab
cleanup?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
