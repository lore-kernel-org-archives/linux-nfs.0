From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/5] VFS: Add VFS helper functions for setting up private
 namespaces
Date: Tue, 23 Jun 2009 19:51:59 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906231950030.3240@localhost.localdomain>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org> <20090622190913.27923.61549.stgit@heimdal.trondhjem.org> <20090623201307.GA25760@us.ibm.com> <1245792589.5133.24.camel@heimdal.trondhjem.org> <20090623223230.GA30173@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37453 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611AbZFXCwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2009 22:52:11 -0400
In-Reply-To: <20090623223230.GA30173@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 23 Jun 2009, Serge E. Hallyn wrote:
>
> (it keeps bugging me that the order of args to list_add() gets reversed
> as a result, but clearly with both starting out empty it doesn't
> matter..)

.. and the new one is more logical. "list_add()" really adds the first 
entry to the list pointed to by the second one. It _works_ the other way 
too in this case, as you point out, but now that you mention it, it really 
looks like the pre-patch code is "wrong".

		Linus
