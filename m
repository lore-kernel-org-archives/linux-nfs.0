From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: stdio and nfs-utils
Date: Wed, 25 Jul 2007 20:07:00 -0400
Message-ID: <20070726000700.GK7943@fieldses.org>
References: <20070725223723.GH7943@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDqsd-0007nE-Uy
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 17:07:00 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDqsh-0006S2-Hm
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 17:07:03 -0700
In-Reply-To: <20070725223723.GH7943@fieldses.org>
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

On Wed, Jul 25, 2007 at 06:37:23PM -0400, J. Bruce Fields wrote:
> I assume what's happening is that the stdio code is taking the error
> returns as a sign that it should leave the data in its buffer and just
> try again next time another fwrite adds more.  Does that make sense?
> I don't really understand how stdio is supposed to handle errors.

So I tried a test program that just does

	while (1) {
		fprintf(f, "%d\n", i++)
		fflush(f);
	}

and pointed it at one of those proc files, which will always return an
error on such a write.  On my fedora rawhide system, each write only
writes the new data.  On my debian sid system, each write writes all the
data accumulated so far.  Huh.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
