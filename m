Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:33966 "EHLO mx1.molgen.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbcABQTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Jan 2016 11:19:42 -0500
Subject: Re: [PATCH v2] NFS: Fix attribute cache revalidation
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <1451491892-11125-1-git-send-email-trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <5687F89B.9040406@molgen.mpg.de>
Date: Sat, 2 Jan 2016 17:19:39 +0100
MIME-Version: 1.0
In-Reply-To: <1451491892-11125-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Though I don't understand the caching code, this one works for me, too.

Together with "NFS: Ensure we revalidate attributes before using 
execute_ok()" and "NFSv4: Don't perform cached access checks before 
we've OPENed the file" it fixes 
https://bugzilla.kernel.org/show_bug.cgi?id=109771

Correctly succeeds or fails after change of x-bit on server.

Regards
   Donald

-- 
Donald Buczek
buczek@molgen.mpg.de
Tel: +49 30 8413 1433

