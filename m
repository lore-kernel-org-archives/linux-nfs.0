Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34194 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757072AbcJXDPX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Oct 2016 23:15:23 -0400
Received: by mail-pf0-f182.google.com with SMTP id r16so89639271pfg.1
        for <linux-nfs@vger.kernel.org>; Sun, 23 Oct 2016 20:15:23 -0700 (PDT)
Date: Mon, 24 Oct 2016 11:15:19 +0800
From: Eryu Guan <guaneryu@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: upstream server crash
Message-ID: <20161024031519.GN2462@eguan.usersys.redhat.com>
References: <20161023182115.GA14481@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161023182115.GA14481@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 23, 2016 at 02:21:15PM -0400, J. Bruce Fields wrote:
> I'm getting an intermittent crash in the nfs server as of
> 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
> pointers for RPC Call and Reply messages".
> 
> I haven't tried to understand that commit or why it would be a problem yet, I
> don't see an obvious connection--I can take a closer look Monday.
> 
> Could even be that I just landed on this commit by chance, the problem is a
> little hard to reproduce so I don't completely trust my testing.

I've hit the same crash on 4.9-rc1 kernel, and it's reproduced for me
reliably by running xfstests generic/013 case, on a loopback mounted
NFSv4.1 (or NFSv4.2), XFS is the underlying exported fs. More details
please see

http://marc.info/?l=linux-nfs&m=147714320129362&w=2

Thanks,
Eryu
