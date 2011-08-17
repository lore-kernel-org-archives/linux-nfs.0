Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43182 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab1HQBk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 21:40:29 -0400
Date: Tue, 16 Aug 2011 21:40:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: open() of device special files
Message-ID: <20110817014026.GD9923@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 09:03:30AM -0700, Myklebust, Trond wrote:
> Hmm... NFS4ERR_INVAL means 'invalid argument', which is not the case
> here; all the arguments that the client is passing to the server are
> valid, however the file cannot be opened because the pathname resolves
> on the server to a file of the wrong type.
> 
> I can't see any other error definition that is "obviously correct", but
> it looks to me as if NFS4ERR_SYMLINK might be the closest thing. One
> reason is the dot-x file defines NFS4ERR_SYMLINK as meaning "should be
> file/directory". The other reason is that NFS4ERR_SYMLINK should
> _always_ trigger the correct behaviour on a client: a fresh lookup of
> the component.

By the way, note rfc 5661 is unambiguous: the server should return
WRONG_TYPE.  I haven't looked into fixing that yet on either client or
server side yet.

--b.
