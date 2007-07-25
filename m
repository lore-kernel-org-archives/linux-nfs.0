From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: stdio and nfs-utils
Date: Wed, 25 Jul 2007 18:37:23 -0400
Message-ID: <20070725223723.GH7943@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDpTv-0007O2-E4
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 15:37:23 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDpTy-0000k1-3c
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 15:37:27 -0700
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

I ran into some problem yesterday where ls on a directory containing
several unexported mountpoints was hanging.  Watching writes to the
/proc/net/rpc/nfsd.export/channel file, what I saw was:

	write("gss/krb5i /path/a expiry\n") -> -ENOENT
	write("gss/krb5i /path/a expiry\ngss/krb5i /path/b\n" -> -ENOENT
	write("gss/krb5i /path/a expiry\ngss/krb5i /path/b\ngss/krb5i/path/b\n) ->ENOENT

etc.  You get the idea.  The cache code that handles the write throws
away all but the first line, so the extra lines are ignored.  The kernel
keeps doing upcalls to ask about /path/b, but never sees the results
because mountd keeps passing down the /path/a downcall again as the
first line each time.

I don't see how nfs-utils itself could be producing multiple lines in
the upcall handler, so I assume what's happening is that the stdio code
is taking the error returns as a sign that it should leave the data in
its buffer and just try again next time another fwrite adds more.  Does
that make sense?  I don't really understand how stdio is supposed to
handle errors.

The -ENOENTs are spurious in this case, actually;  I'll submit a patch
to eliminate them.  But could we also just ditch the use of stdio in all
the nfs-utils cache code?  The current problem aside it seems likely to
complicate any error handling (which the current nfs-utils code doesn't
even attempt).

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
