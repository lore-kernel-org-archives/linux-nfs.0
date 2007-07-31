From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Attribute timeout handling and wrapping
	u32	jiffies
Date: Tue, 31 Jul 2007 15:47:33 -0400
Message-ID: <1185911253.6700.52.camel@localhost>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
	<20070727015900.GA3000@sleipnir.redhat.com>
	<20070731162503.GC2964@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFxgz-0006pu-Lh
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 12:47:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18EaRRi3z/9ZgmwB3nHs64T2M3jZrtcFL0=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFxh1-0004qQ-4a
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 12:47:45 -0700
In-Reply-To: <20070731162503.GC2964@sleipnir.redhat.com>
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

On Tue, 2007-07-31 at 13:25 -0300, Fabio Olive Leite wrote:
> Hi Trond,
> 
> On Thu, Jul 26, 2007 at 10:59:00PM -0300, Fabio Olive Leite wrote:
> > 
> > Tried it out and it behaves correctly. Thanks for your suggestions.
> > The patch below is the final version, and fixes the attribute
> > timeout issue with wrapping jiffies.
> > 
> > ...
> 
> Have you had a chance to review/commit this patch? Should I do any
> more testing on it?

It looked good when I laster reviewed it, but I haven't yet tested it
myself. Please send me a reminder if you don't see it appear in the next
NFS_ALL release (which should be within a week).

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
