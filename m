Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261Ab1K3Izp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 03:55:45 -0500
In-Reply-To: <20111130071319.GA16711@onthe.net.au>
References: <20111130071319.GA16711@onthe.net.au> <1321861008-20611-1-git-send-email-chris@onthe.net.au> <20111129082501.GA569@onthe.net.au> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
To: Chris Dunlop <chris@onthe.net.au>, Al Viro <viro@zeniv.linux.org.uk>
Cc: dhowells@redhat.com, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Date: Wed, 30 Nov 2011 08:54:43 +0000
Message-ID: <24960.1322643283@redhat.com>
From: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chris Dunlop <chris@onthe.net.au> wrote:

> To avoid other people further wasting their and your time on
> exactly the same thing future, how something like the following
> patch, based on your comment in:
> 
> http://article.gmane.org/gmane.linux.nfs/40370
> 
> ...and, if that's acceptable, is it worthwhile doing for the
> other file systems which are likewise currently vulnerable when
> abused by broken layered file systems?

Also, this may get fixed by Al's atomic open patches - but obviously it hasn't
been yet...

> Don't oops when abused by broken layered file systems
> 
> Signed-off-by: Chris Dunlop <chris@onthe.net.au>

Acked-by: David Howells <dhowells@redhat.com>

It's also worth printing a message - this *is* a kernel bug of some description
if it happens.

David
