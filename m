From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: libnfsidmap
Date: Thu, 15 Nov 2007 09:12:12 -0500
Message-ID: <4d569c330711150612n57d4f4deud19532569b2214d8@mail.gmail.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
	<1195024312.19850.130.camel@serendib.melbourne.sgi.com>
	<4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
	<1195122558.19850.146.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Harshula <harshula@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsfS6-0007kZ-B5
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 06:12:19 -0800
Received: from rv-out-0910.google.com ([209.85.198.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IsfSB-0003S7-3n
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 06:12:24 -0800
Received: by rv-out-0910.google.com with SMTP id g11so1798513rvb
	for <nfs@lists.sourceforge.net>; Thu, 15 Nov 2007 06:12:12 -0800 (PST)
In-Reply-To: <1195122558.19850.146.camel@serendib.melbourne.sgi.com>
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

On Nov 15, 2007 5:29 AM, Harshula <harshula@sgi.com> wrote:
> Hi Kevin,
>
> On Wed, 2007-11-14 at 09:59 -0500, Kevin Coffman wrote:
>
> > 1) this doesn't account for other cases where there is no mapping.
>
> In practise, what are the "other cases" where a failed
> nfs4_gss_princ_to_ids() lookup needs to be mapped to 'nobody'?

You have cross-realm Kerberos trusts set up.  A user from a different
Kerberos realm comes to your server and you have no local mapping for
that user.

A new local user is created, but has not yet been placed in the mappings.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
