From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,
	PATCH 3/3] knfsd: Modify write_ports to use svc_find_xprt service
Date: Thu, 11 Oct 2007 13:00:58 +1000
Message-ID: <18189.37354.527748.91357@notabene.brown>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011022901.3501.5244.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfoIR-0001ir-3e
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 20:01:11 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfoIS-0002CH-Ut
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 20:01:14 -0700
In-Reply-To: message from Tom Tucker on Wednesday October 10
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

On Wednesday October 10, tom@opengridcomputing.com wrote:
>  		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {

We should give a bit of thought to this parsing and future expansion.
Suppose we did want to pump more information into the kernel as has
been suggested (e.g. local IP address), we would want this code to
handle the new format correctly, probably by failing.

So maybe we really want

>  		if (sscanf(buf, "%15s %4d%c", transport, &port, &nl) == 2
	            && nl == '\n') {

or something like that???

BTW, I'm fairly happy with the state of this patch set and suggest
that we aim for 2.6.24-rc1.  I still want to read through the final
code with all patches applied, but I should be able to find time for
that in the next month or so.  I don't expect any significant issues.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
