From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: librpcsecgss-0.15 still uses GSSAPI_CFLAGS
Date: Thu, 6 Sep 2007 13:21:53 -0400
Message-ID: <4d569c330709061021l277907e7vc8e5bf4535221079@mail.gmail.com>
References: <200709061317.22165.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Mike Frysinger" <vapier@gentoo.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITL3A-0006V6-8X
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 10:21:52 -0700
Received: from rv-out-0910.google.com ([209.85.198.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITL3C-0008EL-MW
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 10:21:57 -0700
Received: by rv-out-0910.google.com with SMTP id g11so624115rvb
	for <nfs@lists.sourceforge.net>; Thu, 06 Sep 2007 10:21:54 -0700 (PDT)
In-Reply-To: <200709061317.22165.vapier@gentoo.org>
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

yes, sorry.  There is a 0.16 version available that should fix this.

A new version of librpcsecgss is now available from:

http://www.citi.umich.edu/projects/nfsv4/linux/librpcsecgss/librpcsecgss-0.16.tar.gz

Changes since librpcsecgss-0.15:

       * Patch from Guillaume Rousse <Guillaume.Rousse@inria.fr>
         Fix include path to find gssglue headers.

It was also updated to include a change to librpcsecgss.pc.in to
change libgssapi to libgssglue in the Requires line.

On 9/6/07, Mike Frysinger <vapier@gentoo.org> wrote:
> looks like src/Makefile.am needs a quick fixup to use GSSGLUE_CFLAGS rather
> than GSSAPI_CFLAGS ... i'd check cvs to see if this were already done, but i
> have no idea where these projects are kept as they dont seem to be on sf.net
> -mike
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
