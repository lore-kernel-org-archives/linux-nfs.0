From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Attribute timeout handling and wrapping
	u32	jiffies
Date: Wed, 25 Jul 2007 10:32:59 -0400
Message-ID: <1185373979.6585.81.camel@localhost>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDhvC-0003gF-TC
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:33:03 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19OpZHPXBweqBewBvEidyuvlpim/7jamRI=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDhvF-0002rH-MJ
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:33:06 -0700
In-Reply-To: <20070725142824.GA24321@sleipnir.redhat.com>
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

On Wed, 2007-07-25 at 11:28 -0300, Fabio Olive Leite wrote:
> On Wed, Jul 25, 2007 at 10:00:13AM -0400, Trond Myklebust wrote:
> > >  
> > > +#define timeout_or_wrap(a,b,c)	\
> > > +	(typecheck(unsigned long, a) && \
> > > +	 typecheck(unsigned long, b) && \
> > > +	 ((a) < (b) || (a) - (b) > (c)))
> > > +
> > 
> > Ugly name. Besides, the above macro causes problems at the wraparound
> > boundary when (b) may indeed be < (a), but we're still in the allowed
> > range. There is also no guarantee that (c) is unsigned. How about
> > 
> > #define time_in_range(a,b,c) \
> > 	(time_after_eq(a,b) && \
> > 	 time_before_eq(a,c))
> > 
> > instead?
> 
> Hmmm (a) is the "current" jiffies, (b) is the "stored" jiffies, and
> both are always unsigned long. But (c) is the timeout constant, and I
> thought better not to assume typing info there, as a small integer
> fits in many types.
> 
> I think that in the second check you mean this:
> 
> #define time_in_range(a,b,c) \
> 	(time_after_eq(a,b) && \
> 	 time_before_eq(a,b+c))

No. IMO [b;c] should be the range for the generic function, and it
should be up to the NFS code to do the 'stored jiffies + constant
timeout' calculation. You will note that time_in_range() does in any
case return true if you are inside the valid time range, so you will
usually want to do

if (!time_in_range())...

in order to do the timeout_or_wrap() test.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
