Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933399Ab1JYNah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 09:30:37 -0400
Date: Tue, 25 Oct 2011 09:30:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V8 00/26]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20111025133016.GC15662@fieldses.org>
References: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111024091716.GA1109@fieldses.org>
 <20111024094910.GA28693@infradead.org>
 <20111024110759.GA1863@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111024110759.GA1863@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 24, 2011 at 07:07:59AM -0400, J. Bruce Fields wrote:
> On Mon, Oct 24, 2011 at 05:49:10AM -0400, Christoph Hellwig wrote:
> > After all this techical work (which was brought up before) has been
> > done you can resubmit it.  And that point you'd better have very
> > good and very lengthy rationale for why adding an utterly stupid
> > ACL model is supposed to be a good idea.
> 
> It's the ACL model that Samba and NFSv4 clients use, and we want to do a
> better job of exporting linux filesystems to those clients.
> 
> I don't know how to make the justification much longer than that.

OK, sorry, that's not quite fair; we should add details about experience
with alternative approaches in nfsd and samba (mapping between ACL
models, adding "posix" acl support to the protocols, making the protocol
daemon store and enforce the ACL instead of the filesystem).  And
probably cc: samba-technical on that one message so they can confirm or
deny any of that.

--b.
