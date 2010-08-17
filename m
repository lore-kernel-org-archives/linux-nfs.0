Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536Ab0HQNaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 09:30:11 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o7HDUBfJ004642
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 09:30:11 -0400
Received: from tlielax.poochiereds.net (vpn-10-208.rdu.redhat.com [10.11.10.208])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o7HDUAfw016083
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 09:30:10 -0400
Date: Tue, 17 Aug 2010 09:30:09 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: should sillyrename be an asynchronous operation?
Message-ID: <20100817093009.74800ec7@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We had a bug report recently where someone was complaining about
silly-renamed files being left around:

https://bugzilla.redhat.com/show_bug.cgi?id=511901

...they attached a reproducer to the bug which involves a
pthreads-based program killing a child thread that's unlinking and
closing a file.

The unlink triggers a sillyrename (since the file is still open). The
parent kills the child thread and if timed just right, the child thread
will be killed after the RENAME call is issued but before the reply is
processed. The file will end up renamed on the server, but the client
won't be aware of it and won't unlink it during dentry_iput.

It's a bit of work, but the best way I can envision to fix this would
be to make sillyrename do an asynchronous RENAME call, and have it wait
for the reply. If the task is killed, then the RENAME can proceed and
the file would be unlinked when the dput is done by the rpc_release
call.

At this point, I just want to know whether this approach is acceptable
before I spend time on it. Is there a better way to handle this?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
