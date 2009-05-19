From: Rob Gardner <rob.gardner@hp.com>
Subject: Huge race in lockd for async lock requests?
Date: Tue, 19 May 2009 14:43:37 -0600
Message-ID: <4A1319F9.90304@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:1061 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbZESUnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2009 16:43:37 -0400
Received: from g5t0012.atlanta.hp.com (g5t0012.atlanta.hp.com [15.192.0.49])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g1t0026.austin.hp.com (Postfix) with ESMTPS id D2A74C07A
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2009 20:43:38 +0000 (UTC)
Received: from [15.238.15.51] (puedo.americas.hpqcorp.net [15.238.15.51])
	by g5t0012.atlanta.hp.com (Postfix) with ESMTPSA id 7050B10026
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2009 20:43:38 +0000 (UTC)
In-Reply-To: <4A1168E0.3090409@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've got a question about lockd in conjunction with a filesystem that 
provides its own (async) locking.

After nlmsvc_lock() calls vfs_lock_file(), it seems to be that we might 
get the async callback (nlmsvc_grant_deferred) at any time. What's to 
stop it from arriving before we even put the block on the nlm_block 
list? If this happens, then nlmsvc_grant_deferred() will print "grant 
for unknown block" and then we'll wait forever for a grant that will 
never come.

Seems like we ought to do nlmsvc_insert_block() before vfs_lock_file() 
at the very least; But this still leaves problems where the lock is 
granted via the callback while we're still in nlmsvc_lock(), and we 
ignore it and tell the client that the lock is blocked; Now they'll have 
to retry before getting the lock.

Any thoughts on this besides "give up on using lockd"?

Rob Gardner

