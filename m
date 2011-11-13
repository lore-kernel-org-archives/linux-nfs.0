Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52857 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab1KMQgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 11:36:47 -0500
Date: Sun, 13 Nov 2011 11:36:32 -0500
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: NeilBrown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111113163632.GA28574@fieldses.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 13, 2011 at 02:45:48PM +0100, Tigran Mkrtchyan wrote:
> I have a server which runs on top of hadoop. The problem with hadoop
> is that there is no way to have persistent file handles. I am
> currently working on a way to do that - either simulate them or add a
> support for unique file id to hadoop. If linux client will support
> volatile file handles then I can stop inventing some workarounds.

I might call that "fixing" rather than inventing workarounds.

Our of curiosity: if we really wanted to support such filesystems, what
would we need in the protocol?  Just saying "filehandles aren't stable,
deal with it" seems insufficient. 

Say there was some way for the client to indicate which filehandles it
currently has in use, and some way for the server to ask the client to
return in-use filehandles if there are too many (like DELEG_RECALL_ANY).
Then the server could at least place a limit on the number of
filehandles that it had to guarantee persistent.

And/or the client could get a callback on rename/link/unlink.  Bah.

Would any of that actually be easier than implementing persistent file
handles?

--b.
