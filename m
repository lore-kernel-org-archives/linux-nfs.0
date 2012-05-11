Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:53184 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab2EKNuy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 09:50:54 -0400
Message-ID: <4FAD1934.8070908@parallels.com>
Date: Fri, 11 May 2012 17:50:44 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: [RFC] NFSd laundromat containerization
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.
I'm currently looking on NFSd laundromat work, and it looks like have to be 
performed per networks namespace context.
It's easy to make corresponding delayed work per network namespace and thus gain 
per-net data pointer in laundromat function.
But here a problem appears: network namespace is required to skip clients from 
other network namespaces while iterating over global lists (client_lru and friends).
I see two possible solutions:
1) Make these list per network namespace context. In this case network namespace 
will not be required - per-net data will be enough.
2) Put network namespace link on per-net data (this one is easier, but uglier).

Would be appreciated for any comments.

-- 
Best regards,
Stanislav Kinsbursky
