From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: [PATCH] Attribute timeout handling and wrapping u32
	jiffies
Date: Tue, 31 Jul 2007 13:25:03 -0300
Message-ID: <20070731162503.GC2964@sleipnir.redhat.com>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
	<20070727015900.GA3000@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFvhT-0001ei-Is
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 10:40:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFvhS-0006jV-3F
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 10:40:02 -0700
In-Reply-To: <20070727015900.GA3000@sleipnir.redhat.com>
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

Hi Trond,

On Thu, Jul 26, 2007 at 10:59:00PM -0300, Fabio Olive Leite wrote:
> =

> Tried it out and it behaves correctly. Thanks for your suggestions.
> The patch below is the final version, and fixes the attribute
> timeout issue with wrapping jiffies.
> =

> ...

Have you had a chance to review/commit this patch? Should I do any
more testing on it?

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
