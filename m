From: David Howells <dhowells@redhat.com>
Subject: Re: ->migratepage aops for nfs missing
Date: Tue, 04 Aug 2009 23:02:47 +0100
Message-ID: <25558.1249423367@redhat.com>
References: <1249419186.5377.20.camel@heimdal.trondhjem.org> <20090804202648.GA12484@basil.fritz.box>
Cc: dhowells@redhat.com, Andi Kleen <andi@firstfloor.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60184 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933212AbZHDWC4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 18:02:56 -0400
In-Reply-To: <1249419186.5377.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> The only thing I'm not 100% sure about is fscache, but I think the
> correct thing is just to call nfs_fscache_release_page(). David?

Yes, probably.  Note that that will only release the page unconditionally if
gfp includes __GFP_WAIT.

David
