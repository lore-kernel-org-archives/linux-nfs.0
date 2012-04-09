Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:27320 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779Ab2DIQJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 12:09:29 -0400
Message-ID: <4F830999.5000504@parallels.com>
Date: Mon, 09 Apr 2012 20:08:57 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
References: <4F7F230A.6080506@parallels.com>	<20120406234039.GA20940@fieldses.org>	<4F82C6E3.3030009@parallels.com>	<20120409094743.56932677@tlielax.poochiereds.net>	<4F82F16C.7030303@parallels.com> <20120409112739.6a823d6f@corrin.poochiereds.net>
In-Reply-To: <20120409112739.6a823d6f@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

09.04.2012 19:27, Jeff Layton пишет:
>
> If you allow one container to hand out conflicting locks while another
> container is allowing reclaims, then you can end up with some very
> difficult to debug silent data corruption. That's the worst possible
> outcome, IMO. We really need to actively keep people from shooting
> themselves in the foot here.
>
> One possibility might be to only allow filesystems to be exported from
> a single container at a time (and allow that to be overridable somehow
> once we have a working active/active serving solution). With that, you
> may be able limp along with a per-container grace period handling
> scheme like you're proposing.
>

Ok then. Keeping people from shooting themselves here sounds reasonable.
And I like the idea of exporting a filesystem only from once per network 
namespace. Looks like there should be a list of pairs "exported superblock - 
network namespace". And if superblock is exported already in other namespace, 
then export in new namespace have to be skipped (replaced?) with appropriate 
warning (error?) message shown in log.
Or maybe we even should deny starting of NFS server if one of it's exports is 
shared already by other NFS server "instance"?
But any of these ideas would be easy to implement in RAM, and thus it suits only 
for containers...

-- 
Best regards,
Stanislav Kinsbursky
