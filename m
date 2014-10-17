Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.cs.uchicago.edu ([128.135.164.214]:39288 "EHLO
	mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbaJQOs3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 10:48:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by mx.cs.uchicago.edu (Postfix) with ESMTP id 7ED3C652F3
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 09:42:15 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
	by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id KTVwL9A8BmCF for <linux-nfs@vger.kernel.org>;
	Fri, 17 Oct 2014 09:42:15 -0500 (CDT)
Received: from [128.135.11.26] (derby.cs.uchicago.edu [128.135.11.26])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx.cs.uchicago.edu (Postfix) with ESMTPSA id 15C4E652DE
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 09:42:15 -0500 (CDT)
Message-ID: <54412AC6.7070000@cs.uchicago.edu>
Date: Fri, 17 Oct 2014 09:42:14 -0500
From: Colin Hudler <chudler@cs.uchicago.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: when rpc.mountd flushes auth.unix.gid
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a few hundred computers mounting an NFS server in a typical 
LDAP-based users (nss) setup. We frequently add and remove exports and 
use exportfs -r to update etab. Every time we do so, the clients report 
"NFS server not responding" and start backing off their requests. After 
a painful 3-5 minutes, they recover and life is normal again.

We discovered that when the rpc.mountd cache flushing occurs, our NIS 
system is overwhelmed with grouplist requests and this obviously blocks 
things. We are working on that problem separately, and I admit this to 
be a weakness in our setup. My question is simple.

Why does it flush auth.unix.gid when the etab changed? I think it makes 
unnecessary work for rpc.mountd because the gids are unlikely to have 
changed, and they already have a reasonable expiration policy.

--
Colin
