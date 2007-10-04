From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 04/35] svc: Add a max payload value to the transport
Date: Thu, 4 Oct 2007 11:10:29 +1000
Message-ID: <20071004011029.GP21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192738.3250.6971.stgit@dell3.ogc.int>
	<8E01CAF1-5D8D-4AE5-B15D-C04983079F76@oracle.com>
	<1191342488.1565.8.camel@trinity.ogc.int>
	<20071003110932.GN21388@sgi.com>
	<1191421613.1565.100.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdF9c-0007dT-V0
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:05:51 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+8ekeAEJAJimF+DT5qSwnQlS0HnMauqhQ=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdF9g-0001tN-SL
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:05:34 -0700
In-Reply-To: <1191421613.1565.100.camel@trinity.ogc.int>
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

On Wed, Oct 03, 2007 at 09:26:53AM -0500, Tom Tucker wrote:
> On Wed, 2007-10-03 at 21:09 +1000, Greg Banks wrote:
> > On Tue, Oct 02, 2007 at 11:28:08AM -0500, Tom Tucker wrote:
> I see only one possible benefit of copying the svc_xprt_ops structure
> and that is that it saves one ptr de-reference when calling ops. What's
> the consensus? Copy it, or keep a ptr?

Pointer.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
