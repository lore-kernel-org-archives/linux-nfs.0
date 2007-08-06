From: Jeff Layton <jlayton@redhat.com>
Subject: regression with rmtab handling in newer nfs-utils code
Date: Mon, 6 Aug 2007 15:55:00 -0400
Message-ID: <20070806155500.25869737.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, iisaman@citi.umich.edu, kwc@citi.umich.edu
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II8fL-00019o-RK
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:55:00 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II8fP-0008BQ-M1
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:55:04 -0700
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

I just noticed that there seems to have been a regression with how the
rmtab is handled in the latest nfs-utils code. It seems to have gone
back to adding extra lines to the rmtab that contain the comma-delimited
domain string.

At first glance, it looks like the extra mountlist_add calls that went
in with the patch below are the culprit (though this code seems to have
changed a few times since then). I don't think there's any need to
have cache_export_ent or nfsd_fh call mountlist_add.

Can these calls just be removed, or am I missing something?

commit dbfcba5b03481d49f3e78946fe8fd066e2025545
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Thu Feb 8 17:27:45 2007 -0500

    Remove duplicated code.
    
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    
    Remove duplicated code.
    Signed-off-by: Neil Brown <neilb@suse.de>

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
