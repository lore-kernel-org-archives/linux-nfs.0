From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: new client-side gssd upcall patches
Date: Fri, 12 Dec 2008 13:20:20 -0500
Message-ID: <1229106035-16102-1-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34000 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758583AbYLLSUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:41 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


These patches implement the new client-side text-based gssd upcall,
needed for v4.0 callbacks over krb5, better crypto algorithm support,
etc.

All of this is also available from the for-trond branch at

	git://linux-nfs.org/~bfields/linux.git for-trond

Changes since posted versions (mainly the result of testing from Olga):

	- Fix race in pipe creation ordering: gssd uses existance of the
	  two files ("gssd", the new pipe, and "krb5", the old one), to
	  decide what the kernel supports.  If we create "krb5" first,
	  then there's a moment when gssd could think the kernel only
	  supports the old pipe.  So create "gssd" first.
	- Use different pipe operation structures to distinguish the two
	  pipes, instead of depending on comparing to the two dentries
	  in the auth; much simpler code, and avoids a race on open of a
	  new pipe.
	- Reorder initialization in gss_alloc_msg to fix a trivial null
	  dereference in new upcall case.

Comments?  If they look OK to you, please apply at least the first 9.

I've also appended 6 patches that use the new upcall to support krb5
callbacks.  Note a couple of those touch only nfsd.  I was imagining
we'd keep those all together and submit them through your tree.  If you
don't want to do that, could you just ACK the last 6 patches if they're
OK?  And then I'll figure out what to do with them after the rest goes
in.

--b.
