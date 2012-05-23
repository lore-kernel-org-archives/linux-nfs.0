Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38105 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab2EWMJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 08:09:15 -0400
Message-ID: <4FBCD35D.30702@openvz.org>
Date: Wed, 23 May 2012 16:09:01 +0400
From: Kinsbursky Stanislav <skinsbursky@openvz.org>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] NFS: init client before declaration
References: <20120522124018.338.20817.stgit@localhost.localdomain>  <1337696984.4269.4.camel@lade.trondhjem.org>  <1337698816.4269.15.camel@lade.trondhjem.org>  <4FBBB0DB.6050708@parallels.com>  <1337701904.4269.16.camel@lade.trondhjem.org>  <4FBBBC4C.5010103@parallels.com>  <1337705000.4269.23.camel@lade.trondhjem.org> <1337718771.4269.29.camel@lade.trondhjem.org> <4FBCCA4F.3020600@parallels.com>
In-Reply-To: <4FBCCA4F.3020600@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23.05.2012 15:30, Stanislav Kinsbursky wrote:
> Moreover, looks like pipefs dentries creation have to be synchronized by
> nfs_client_lock somehow... Otherwise because of races we can get a client
> without pipe dentry....

Taking this back.

-- 
Best regards,
Stanislav Kinsbursky

