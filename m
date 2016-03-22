Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40768 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755663AbcCVAM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 20:12:56 -0400
Date: Mon, 21 Mar 2016 20:12:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>, Richard Yao <ryao@gentoo.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160322001255.GA2353@fieldses.org>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
 <20160321223627.GA12999@thunk.org>
 <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 11:48:04PM +0100, Cedric Blancher wrote:
> Old invalid argument, and Sophos and Symatec look there as well.
> 
> If it was a bad idea, why has Linux fs attributes which are almost the
> same as O_XATTR except that they use a custom api? Why does Macos have
> alternate streams (called forks)? Why did Solaris adopt it long ago
> (and still gets support questions about it - just saying before
> someone argues that no one uses THAT)?

Could you point us at some of those users?

--b.
