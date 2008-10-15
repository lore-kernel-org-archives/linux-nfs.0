From: David Howells <dhowells@redhat.com>
Subject: Re: nfsd 2.6.28 merge plans
Date: Wed, 15 Oct 2008 10:17:04 +0100
Message-ID: <14531.1224062224@redhat.com>
References: <1224017504.8907.42.camel@localhost> <20081014120753.7f968845.akpm@linux-foundation.org> <20081008232237.GH14527@fieldses.org> <1228.1224016436@redhat.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46908 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbYJOJRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 05:17:43 -0400
In-Reply-To: <1224017504.8907.42.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> I'm happy with the changes that you made after the plumbers conf, so as
> far as the NFS side of the patches is concerned, we should be close to
> ready to merge.

What I'm hoping is that JamesM will pass my creds patches to Linus in this
merge window - that way you don't need to carry them in your tree as the main
cachefiles patch requires them to deal with security.

David
