From: David Howells <dhowells@redhat.com>
Subject: Re: nfsd 2.6.28 merge plans
Date: Thu, 20 Nov 2008 14:25:55 +0000
Message-ID: <10442.1227191155@redhat.com>
References: <1224017504.8907.42.camel@localhost> <20081014120753.7f968845.akpm@linux-foundation.org> <20081008232237.GH14527@fieldses.org> <1228.1224016436@redhat.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39486 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593AbYKTO0g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Nov 2008 09:26:36 -0500
In-Reply-To: <1224017504.8907.42.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> I'm happy with the changes that you made after the plumbers conf, so as
> far as the NFS side of the patches is concerned, we should be close to
> ready to merge.

Okay...  I've fixed a couple of bugs and now it seems to survive multiple
parallel tars being repeatedly thrown at it.

How do you want to do this?  I could make a GIT tree for you to pull, but it'd
have to be based on James Morris's next branch for the security features
required.

Alternatively, I could supply you with patches or a GIT tree, including the
security patches based on Linus's tree rather than James's.

Or we could wait until after the next merge window and hope Linus pulls them
this time (which he ought to, via James's tree).

David
