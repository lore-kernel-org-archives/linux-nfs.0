Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14372 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932393Ab2AJRnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 12:43:45 -0500
Message-ID: <4F0C789C.5010508@parallels.com>
Date: Tue, 10 Jan 2012 21:42:52 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bjschuma@netapp.com" <bjschuma@netapp.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Bryan.
Are you still on progress with this stuff?
I'm wondering, because I have to reorganize RPC versions and programs code in 
the way to collect statistics per container. I actually have few patches 
already, which implements functionality similar to your new versions adding.
And thus it would be great to know, do i need to take your work into account or not.

-- 
Best regards,
Stanislav Kinsbursky
