Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:64368 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab3KKUcr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 15:32:47 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Charles Edward Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS atime behavior is not documented
Date: Mon, 11 Nov 2013 17:33:10 +0000
Message-ID: <6EE5262F-5B2E-4F10-A600-A60F30C0A23E@netapp.com>
References: <E4BE40FF-9F81-4688-BD39-1E583DDCEA4A@oracle.com>
In-Reply-To: <E4BE40FF-9F81-4688-BD39-1E583DDCEA4A@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 11:50, Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi-
> 
> It was recently pointed out to me that the behavior of atime on NFS mount points is pretty dodgy, yet this is not documented anywhere, not even in the venerable and unmaintained Linux NFS FAQ.
> 
> A good place to cover this topic might be nfs(5).  It could discuss how the Linux NFS client deals with the various *atime mount options (mostly be collapsing them into relatime, all the time).  And it could discuss how file timestamps are updated when the physical backing store is on another system.
> 
> Thoughts?  Comments?

NFS atime is not the same as relatime.

Our atime is only updated when a READ rpc call goes to the server. Cached reads do not, for instance, trigger an atime update. That is a very different model than the relatime model.

Cheers
  Trond