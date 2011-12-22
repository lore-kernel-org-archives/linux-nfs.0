Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149Ab1LVBC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 20:02:27 -0500
Date: Wed, 21 Dec 2011 20:04:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111221200402.1e87326d@corrin.poochiereds.net>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C22@IT-1874.Isys.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
	<1324499696-10318-5-git-send-email-jlayton@redhat.com>
	<46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
	<20111221163312.3405c1f3@tlielax.poochiereds.net>
	<121533D1-9C5C-45EA-AF8F-90AA4167B066@oracle.com>
	<20111221164810.78d600a9@tlielax.poochiereds.net>
	<20111221165922.589101aa@tlielax.poochiereds.net>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C18@IT-1874.Isys.com>
	<20111221172750.638ed046@tlielax.poochiereds.net>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC057ECD1C22@IT-1874.Isys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Dec 2011 17:33:23 -0500
Peter Staubach <pstaubach@exagrid.com> wrote:

> I will need to disagree with the assertion regarding XDR and the packed struct.  XDR can handle a versioned struct very neatly.  It can do so just as easily as text string parsing and with greatly reduced overhead.
> 

Ok, I'll bite -- what does XDR give us in this situation over a packed
struct?

Clearly there are benefits when the producer and consumer may have
considerable differences, as is the case between networked hosts. For
instance, different endianness or word size, etc.

Here though, the producer and consumer are the same host, so we can be
reasonably sure that the endianness is the same. I made sure to define
the struct with explicit sizes for the fields, so word size isn't a
factor. There's also a version field at the head so we could
potentially rev the upcall struct version later if needed. An XDR
format would need the same thing...

AFAICS, Using XDR is just going to add extra overhead here, but not
eliminate any of the drawbacks. If we have to rev the format later,
we'll be in the same situation.

A text based upcall has similar issues too, but it does at least make
debugging simpler. As Chuck points out too, there is some variability
in arguments as well. I think too that we're going to end up adding
some other upcalls here, and those will also need a different set
of arguments from what's there today.

-- 
Jeff Layton <jlayton@redhat.com>
