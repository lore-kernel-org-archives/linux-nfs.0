Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32866 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbcCVBCv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 21:02:51 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: Making an interface for alternative data streams
From: Richard Yao <ryao@gentoo.org>
In-Reply-To: <20160322001255.GA2353@fieldses.org>
Date: Mon, 21 Mar 2016 21:02:46 -0400
Cc: Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Message-Id: <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
References: <56F03945.40208@gentoo.org> <56F05745.50204@gentoo.org> <20160321204041.GA807@fieldses.org> <20160321223627.GA12999@thunk.org> <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com> <20160322001255.GA2353@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 21, 2016, at 8:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Mon, Mar 21, 2016 at 11:48:04PM +0100, Cedric Blancher wrote:
>> Old invalid argument, and Sophos and Symatec look there as well.
>> 
>> If it was a bad idea, why has Linux fs attributes which are almost the
>> same as O_XATTR except that they use a custom api? Why does Macos have
>> alternate streams (called forks)? Why did Solaris adopt it long ago
>> (and still gets support questions about it - just saying before
>> someone argues that no one uses THAT)?
> 
> Could you point us at some of those users?

I am told that Samba users would love this functionality.
> 
> --b.
