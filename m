Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:56404 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab2DXPSO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 11:18:14 -0400
Date: Tue, 24 Apr 2012 11:19:24 -0400
From: Jim Rees <rees@umich.edu>
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4: fix referrals on mounts that use IPv6 addrs
Message-ID: <20120424151924.GA13191@umich.edu>
References: <1335279471-46782-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335279471-46782-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Weston Andros Adamson wrote:

  diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
  index 9c8eca3..307743d 100644
  --- a/fs/nfs/nfs4namespace.c
  +++ b/fs/nfs/nfs4namespace.c
  @@ -52,6 +52,35 @@ Elong:
   }
   
   /*
  + * parse the path component of an nfs path ("<server>:<path>").
  + *  nfspath - the "<server>:<path>" string
  + *  end - pointer to end of devname component of 'nfspath'
  + * returns NULL on failure
  + */

The comment seems odd to me.  You're not parsing the path component, you're
parsing the nfspath to return the path.  And the term "devname component"
hasn't been defined anywhere.  How about this:

Return the path component of an nfs path ("<server>:<path>").
 nfspath - the "<server>:<path>" string
 end - pointer to end of nfspath
returns NULL on failure
