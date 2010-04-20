Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751Ab0DTONB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 10:13:01 -0400
Date: Tue, 20 Apr 2010 10:13:40 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Di Pe <dipeit@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
Message-ID: <20100420101340.6a0652a3@corrin.poochiereds.net>
In-Reply-To: <x2l3b6787961004191737p1fb222uc6a5b03d77414826@mail.gmail.com>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	<j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
	<20100417111001.255ad1f4@tlielax.poochiereds.net>
	<x2l3b6787961004191737p1fb222uc6a5b03d77414826@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 19 Apr 2010 17:37:45 -0700
Di Pe <dipeit@gmail.com> wrote:

> 
> On another Note: This PAC size issue is interesting. It seems to be an
> ongoing problem over the last couple of years. I suspect most
> krb5/gssd developers do not have an Active Directory infrastructure at
> hand they can test against?
> Going forward it may be make sense to "fix" this issue on the
> Microsoft end of things : http://support.microsoft.com/kb/832572 ?
> However, this would result in a pretty unique environment because many
> AD Admins would not bother with this setting nor would they know how
> to apply it.
> 

In order to hit this problem you need a fairly large AD infrastructure.
You need to have the principal in a lot of groups so that the PAC is
big enough to cause the issue.

Also, it's only really a problem if you're using libraries that aren't
able to deal with large ticket sizes like this. Current libtirpc and
librpcsecgss should deal with this just fine.

Certainly if you have the freedom to have the server not store PAC info
for certain tickets, then that's one way to work around the problem.
Many people don't have that freedom, or it's just too much trouble to
do so.

-- 
Jeff Layton <jlayton@redhat.com>
