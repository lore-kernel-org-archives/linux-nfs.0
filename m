From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH] svc: REPOST - Fix the UDP address logic
Date: Thu, 25 Oct 2007 11:56:58 +1000
Message-ID: <20071025015658.GA30105@sgi.com>
References: <20071023181301.11155.90411.stgit@dell3.ogc.int>
	<471F8F27.1040008@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ikrtc-00046O-1p
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 18:52:28 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19OqrpcvAEfUiSwm5G3leX0WFdo4S1t0n8=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ikrtg-00044T-Ez
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 18:52:33 -0700
In-Reply-To: <471F8F27.1040008@oracle.com>
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

On Wed, Oct 24, 2007 at 02:29:59PM -0400, Chuck Lever wrote:
> Tom Tucker wrote:
> > 
> >+static size_t svc_sockaddr_len(struct sockaddr *addr)
> >+{
> >+	switch (addr->sa_family) {
> >+	case AF_INET:
> >+		return sizeof(struct sockaddr_in);
> >+	case AF_INET6:
> >+		return sizeof(struct sockaddr_in6);
> >+	}
> >+	dprintk("svc: unrecognized address family %d\n", addr->sa_family);
> >+	return -ENOTSUPP;
> >+}
> >+
> 
> Nit: sa_family is probably an unsigned short, so use "%u" instead of
> "%d".  Also I'm using -EAFNOSUPPORT in similar error cases, but I may 
> have missed a stated preference.

EAFNOSUPPORT is the most appropriate error.

Also, you might want to make the return the signed ssize_t so that
the return value -EAFNOSUPPORT is actually negative.

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
