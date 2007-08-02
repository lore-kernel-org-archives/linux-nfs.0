From: Jeff Layton <jlayton@redhat.com>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Thu, 2 Aug 2007 12:28:58 -0400
Message-ID: <20070802122858.e977b881.jlayton@redhat.com>
References: <46ADDFB2.9070709@inf.ethz.ch>
	<20070731144824.GA15231@fieldses.org>
	<20070802113255.d686894c.jlayton@redhat.com>
	<20070802160536.GF21282@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Stefan Walter <stefan.walter@inf.ethz.ch>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGdXu-0006dP-Ry
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:29:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGdXx-0003Id-Gy
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:29:10 -0700
In-Reply-To: <20070802160536.GF21282@fieldses.org>
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

On Thu, 2 Aug 2007 12:05:36 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Aug 02, 2007 at 11:32:55AM -0400, Jeff Layton wrote:
> > On Tue, 31 Jul 2007 10:48:24 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > That's an interesting problem.  Thanks for the report!
> > > 
> > > I don't believe that long comma-delimited string actually has any
> > > meaning to the kernel--as far as the kernel is concerned, it's just an
> > > opaque object that will be passed back to mountd later (along with a
> > > path name) to get export options.
> > > 
> > > So I suppose that string could be replaced by a hash, or maybe even just
> > > by the ip address of the particular host--the disadvantage to the latter
> > > being that it would require the kernel to keep a separate export for
> > > each client address.
> > 
> > I started having a look at this today. The original patches that I
> > proposed to clean up the rmtab a few months ago also eliminated this
> > comma-delimited string. Neil had valid objections to it at the time,
> > but if we switched to using the IP address as a cache key like Bruce
> > describes then doing that becomes more reasonable.
> > 
> > The only downside I see is the one Bruce points out -- the size of
> > the kernel export cache would increase. I don't have a feel for whether
> > this is a show stopper, however.
> 
> Yeah, there might be some risk of solving that problem at the expense of
> people with tons of clients all matching *.example.com.  The actual
> export objects are actually pretty small--68 bytes, last I checked?
> You'd also need two upcalls to mountd per client (for ip address and
> export, as opposed to just ip address).  I don't know what other costs
> there might be.
> 

Yeah, that could make using the ipaddr too costly...

> What about the idea of hashing the comma-delimited list and passing
> that?  You'd want hash large enough to be collision-free--might as well
> use some cryptographic hash, I guess, though it may be mild overkill.
> Is there any reason why that wouldn't work?
> 

Hashing would certainly work. The only issue though is that this
doesn't take care of the second problem, which is that NFSCLNT_IDMAX is
too small for some environments. So this change would need to be
coupled with an increase in this hardcoded value, change m_hostname to
be dynamically allocated, or change the comma-delimited string to some
other scheme entirely (maybe a linked list of some sort?).

As far as the hashing scheme, I guess we could use the glibc crypt()
routine that does md5 hashing. I'd like to avoid adding dependencies
on new libs if possible.

> Could you remind me what problems you were trying to fix with your rmtab
> cleanup?
>

Those patches were really intended to get showmount -a to look correct.
My first pass at it changed the m_hostname field to hold an actual
hostname, got rid of the comma-separated strings and just had mountd do
repeated calls to client_check to check the host's validity.

This was problematic though with a multi-homed client though since the
export table key then became a hostname rather than the comma-delimited
string and more than 1 ip addr could resolve to it. If we use the ipaddr
as a key, then this problem goes away, but then we have the other issues
you've detailed above.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
