From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: question on the inner workings of NFS soft mount
Date: Thu, 26 Jul 2007 18:42:40 -0400
Message-ID: <1185489760.6585.269.camel@localhost>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD82FA070@exchrdm.ad.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wim Colgate <Wim.Colgate@xensource.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEC2d-00074i-9l
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 15:42:43 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1812LkWTC+7e5jktn+CL7G+wVArdsNWyOc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEC2f-0006PL-Nl
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 15:42:47 -0700
In-Reply-To: <A9AD3C3BCF83FD4182B7D4D99E37FAD82FA070@exchrdm.ad.xensource.com>
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

On Thu, 2007-07-26 at 15:39 -0700, Wim Colgate wrote:
> Sure thing, I'll try UDP. One thing I forgot to add is that if the cable
> is unplugged, the times are nicely 300ms timeouts -- which must eschew
> any TCP backoff if the host is unreachable.

Yup. The error values returned by the networking layer are different,
and so we don't worry so much about exponential backoff.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
