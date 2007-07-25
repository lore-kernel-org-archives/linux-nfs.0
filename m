From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: [PATCH] Attribute timeout handling and wrapping u32
	jiffies
Date: Wed, 25 Jul 2007 11:54:01 -0300
Message-ID: <20070725145401.GB24321@sleipnir.redhat.com>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDiFG-00067C-Mu
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:53:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IDiFJ-0006ip-Bp
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:53:50 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l6PErl0H013667
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 10:53:47 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l6PErl25013411
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 10:53:47 -0400
Received: from sleipnir.redhat.com (vpn-14-148.rdu.redhat.com [10.11.14.148])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id
	l6PErjK0008699
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 10:53:46 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l6PEs2fr025856
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 11:54:04 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l6PEs122025855
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 11:54:01 -0300
In-Reply-To: <1185373979.6585.81.camel@localhost>
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

On Wed, Jul 25, 2007 at 10:32:59AM -0400, Trond Myklebust wrote:
> > =

> > I think that in the second check you mean this:
> > =

> > #define time_in_range(a,b,c) \
> > 	(time_after_eq(a,b) && \
> > 	 time_before_eq(a,b+c))
> =

> No. IMO [b;c] should be the range for the generic function, and it
> should be up to the NFS code to do the 'stored jiffies + constant
> timeout' calculation.

OK. That makes sense, since we then only care about jiffy values and
can assume typing.

> You will note that time_in_range() does in any
> case return true if you are inside the valid time range, so you will
> usually want to do
> =

> if (!time_in_range())...
> =

> in order to do the timeout_or_wrap() test.

Indeed, and the code also looks more readable.

Let's see how it behaves.

Regards,
F=E1bio
-- =

ex sed lex awk yacc, e pluribus unix, amem

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
