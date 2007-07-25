From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: [PATCH] Attribute timeout handling and wrapping u32
	jiffies
Date: Wed, 25 Jul 2007 11:28:24 -0300
Message-ID: <20070725142824.GA24321@sleipnir.redhat.com>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDhqZ-0003AY-7f
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:28:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IDhqb-0001HM-PD
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:28:19 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l6PES9IS030407
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 10:28:09 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l6PES8jU031977
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 10:28:08 -0400
Received: from sleipnir.redhat.com (vpn-14-148.rdu.redhat.com [10.11.14.148])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id
	l6PES6TV032113
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 10:28:07 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l6PESQbU025193
	for <nfs@lists.sourceforge.net>; Wed, 25 Jul 2007 11:28:27 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l6PESPYn025192
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 11:28:25 -0300
In-Reply-To: <1185372013.6585.73.camel@localhost>
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

On Wed, Jul 25, 2007 at 10:00:13AM -0400, Trond Myklebust wrote:
> >  =

> > +#define timeout_or_wrap(a,b,c)	\
> > +	(typecheck(unsigned long, a) && \
> > +	 typecheck(unsigned long, b) && \
> > +	 ((a) < (b) || (a) - (b) > (c)))
> > +
> =

> Ugly name. Besides, the above macro causes problems at the wraparound
> boundary when (b) may indeed be < (a), but we're still in the allowed
> range. There is also no guarantee that (c) is unsigned. How about
> =

> #define time_in_range(a,b,c) \
> 	(time_after_eq(a,b) && \
> 	 time_before_eq(a,c))
> =

> instead?

Hmmm (a) is the "current" jiffies, (b) is the "stored" jiffies, and
both are always unsigned long. But (c) is the timeout constant, and I
thought better not to assume typing info there, as a small integer
fits in many types.

I think that in the second check you mean this:

#define time_in_range(a,b,c) \
	(time_after_eq(a,b) && \
	 time_before_eq(a,b+c))

I'll see about testing this new macro in my test box and will report
back soon.

Thanks,
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
