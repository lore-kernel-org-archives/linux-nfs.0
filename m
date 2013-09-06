Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758695Ab3IFQHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 12:07:42 -0400
Date: Fri, 6 Sep 2013 12:07:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130906160735.GA16396@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
 <20130905204536.GB24805@fieldses.org>
 <20130905233449.5eb8bf79@galadriel.home>
 <20130905214002.GD24805@fieldses.org>
 <20130906175721.30082c11@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130906175721.30082c11@harpe.intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 06, 2013 at 05:57:21PM +0200, Emmanuel Florac wrote:
> Le Thu, 5 Sep 2013 17:40:02 -0400
> "J. Bruce Fields" <bfields@fieldses.org> écrivait:
> 
> > I was asking about the on-the-wire errors and getattr replies here,
> > not the application system calls.
> > 
> 
> OK, I've done the dump; I've kept just the last few working calls, then
> the failure calls, and filtered for NFS traffic (there are SSH and
> LACP frames interspersed here). I have absolutely no idea about what's
> going on there :) Any light from the network savvy?

Weird.  Things look normal up through frame 14, which is a READDIRPLUS
reply.  Then the server resends the reply after .2s, and and the client
resends its call shortly thereafter (but without acking the latest
reply).  And then the rest of the trace is resends of the reply.

So it looks like the client stopped ACKing the server's replies?

You may also have filtered out some TCP ACKs, which makes this harder to
work out.

Looks like a networking problem, but I don't know.

--b.
