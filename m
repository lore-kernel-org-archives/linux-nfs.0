From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Tue, 17 Mar 2009 16:25:01 -0400
Message-ID: <20090317202501.GD32331@fieldses.org>
References: <49B57FB2.9020000@RedHat.com> <A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com> <49BFFDA6.8090500@RedHat.com> <C0503E0B-59F4-46BA-9430-08C34B2F693E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50648 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbZCQUZH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2009 16:25:07 -0400
In-Reply-To: <C0503E0B-59F4-46BA-9430-08C34B2F693E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 17, 2009 at 04:17:05PM -0400, Chuck Lever wrote:
> I think the problem I have with this (besides the complexity) is that  
> if we must add more ways of avoiding NFSv4, then is NFSv4 really ready  
> to be made the default?

Even given the best possible client and server implementation, there are
enough user-visible not-completely-backwards-compatible changes in the
protocol (ACLs, string names, etc.) that silently substituting v4 can't
be the right thing for every case.

--b.
