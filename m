From: Harshula <harshula@sgi.com>
Subject: Re: libnfsidmap
Date: Thu, 15 Nov 2007 21:29:17 +1100
Message-ID: <1195122558.19850.146.camel@serendib.melbourne.sgi.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
	<1195024312.19850.130.camel@serendib.melbourne.sgi.com>
	<4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Isbza-0002v8-OG
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 02:30:38 -0800
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18fB1n7RFo3J0gy7EEMm3BS5B4zkB9Y1NY=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Isbze-0003QU-G3
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 02:30:44 -0800
In-Reply-To: <4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
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

Hi Kevin,

On Wed, 2007-11-14 at 09:59 -0500, Kevin Coffman wrote:

> 1) this doesn't account for other cases where there is no mapping.

In practise, what are the "other cases" where a failed
nfs4_gss_princ_to_ids() lookup needs to be mapped to 'nobody'?

> 2) a later version of nfs-utils allows root to use any credentials
> (does not use machine credentials for all accesses by root), which
> will defeat this check.

Thanks for the heads-up.

cya,
#


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
