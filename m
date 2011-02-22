Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:45904 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725Ab1BVQmq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 11:42:46 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1PrvK0-00062i-4b
	for linux-nfs@vger.kernel.org; Tue, 22 Feb 2011 17:42:44 +0100
From: Ferenc Wagner <wferi@niif.hu>
To: linux-nfs@vger.kernel.org
Subject: Re: Seemingly inconsistent directory state under NFSv4
References: <87sjvuiwnl.fsf@tac.ki.iif.hu>
Date: Tue, 22 Feb 2011 17:42:44 +0100
In-Reply-To: <87sjvuiwnl.fsf@tac.ki.iif.hu> (Ferenc Wagner's message of "Fri,
	11 Feb 2011 13:27:26 +0100")
Message-ID: <87d3mkhvgb.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ferenc Wagner <wferi@niif.hu> writes:

> In our somewhat mixed NFSv4 setup (Linux 2.6.32 Debian squeeze server, a
> 2.6.26 and a 2.6.32 Debian lenny client) we sometimes experience the
> following: removing a file on the 2.6.26 client makes that file
> disappear from the directory listing of the 2.6.32 client, but the file
> itself remains accessible by its old -- now nonexistent -- name there.
> Is such a confusing state expected, or is this the manifestation of some
> bug?

Is this perhaps a manifestation of the following paragraph of
nfs41-server.txt in the Linux kernel documentation?

    Incomplete delegation enforcement: if a file is renamed or
    unlinked, a client holding a delegation may continue to
    indefinitely allow opens of the file under the old name.

If yes, is there a way to list the active delegations (on the server and
on the client) and possibly trigger releasing/recalling them?
-- 
Thanks,
Feri.
