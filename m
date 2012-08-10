Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:52922 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786Ab2HJSbq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 14:31:46 -0400
Message-ID: <5025537D.9060300@zytor.com>
Date: Fri, 10 Aug 2012 11:31:25 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Trond.Myklebust@netapp.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, eric.dumazet@gmail.com, xemul@parallels.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, viro@zeniv.linux.org.uk,
        tim.c.chen@linux.intel.com, devel@openvz.org
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk>
In-Reply-To: <20120810192628.79a34d28@pyramind.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2012 11:26 AM, Alan Cox wrote:
>> On that whole subject...
>>
>> Do we need a Unix domain socket equivalent to openat()?
> 
> I don't think so. The name is just a file system indexing trick, it's not
> really the socket proper. It's little more than "ascii string with
> permissions attached" - indeed we also support an abstract name space
> which for a lot of uses is actually more convenient.
> 

I don't really understand why Unix domain sockets is different than any
other pathname users in this sense.  (Actually, I have never understood
why open() on a Unix domain socket doesn't give the equivalent of a
socket() + connect() -- it would make logical sense and would provide
additional functionality).

It would be different if the Unix domain sockets simply required an
absolute pathname (it is not just about the root, it is also about the
cwd, which is where the -at() functions come into play), but that is not
the case.

The abstract namespace is irrelevant for this, obviously.

> AF_UNIX between roots raises some interesting semantic questions when
> you begin passing file descriptors down them as well.

Why is that?  A file descriptor carries all that information with it...

	-hpa
