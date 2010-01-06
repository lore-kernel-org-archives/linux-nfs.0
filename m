From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils
	(try #3)
Date: Wed, 6 Jan 2010 15:33:13 -0500
Message-ID: <20100106203312.GL6612@fieldses.org>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com> <20100106191706.GE6612@fieldses.org> <20100106144247.18dc10de@tlielax.poochiereds.net> <20100106195819.GH6612@fieldses.org> <77AF3FCC-A3BF-49C6-BF21-B1C38FD867AB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59223 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756244Ab0AFUcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 15:32:24 -0500
In-Reply-To: <77AF3FCC-A3BF-49C6-BF21-B1C38FD867AB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 06, 2010 at 03:22:55PM -0500, Chuck Lever wrote:
> My original idea was that this facility would be a set of smaller unit  
> tests.  Since some of statd/sm-notify is now broken out into libraries, I 
> think that makes it a little easier to craft targeted tests that don't 
> require a full-blown statd running to carry out (Of course, that's 
> speculation; I could be wrong, and Jeff has kindly set up the code for us 
> to test this theory!).
>
> The old code has a statd simulator that doesn't require root, and uses  
> its own RPC program number.  It might be reasonable to adopt that  
> approach instead of using the real statd, for some test cases.

Like I say, it might be nice to be able to add even more intrusive tests
(e.g. that modify the exports and then test the results over "lo" with
the kernel client), so I'm actually happy Jeff says he's not bending
over backwards to make the tests unprivileged.

> Another way to set this up might be to use a container, or run it under a 
> lightweight kvm.

Sounds ambitious for now.

--b.
