Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63383 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab3KCCXb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 22:23:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>
Subject: Re: [PATCH] nfs: set security label when revalidating inode
Date: Sun, 3 Nov 2013 02:23:29 +0000
Message-ID: <C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 2, 2013, at 6:57, Jeff Layton <jlayton@redhat.com> wrote:

> Currently, we fetch the security label when revalidating an inode's
> attributes, but don't apply it. This is in contrast to the readdir()
> codepath where we do apply label changes.

OK. Why should we not just throw out the code that fetches the security label here?

IOW: what is the caching model that is being implemented in this patch; is it just “fetch label at random intervals” or is there real method to the madness?

Trond