Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41967 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab3IJN2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 09:28:42 -0400
Date: Tue, 10 Sep 2013 09:28:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130910132841.GC16011@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
 <20130905204536.GB24805@fieldses.org>
 <20130905233449.5eb8bf79@galadriel.home>
 <20130905214002.GD24805@fieldses.org>
 <20130906175721.30082c11@harpe.intellique.com>
 <20130906160735.GA16396@fieldses.org>
 <20130906185508.3f0d2730@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130906185508.3f0d2730@harpe.intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 06, 2013 at 06:55:08PM +0200, Emmanuel Florac wrote:
> Le Fri, 6 Sep 2013 12:07:35 -0400
> "J. Bruce Fields" <bfields@fieldses.org> écrivait:
> 
> > Weird.  Things look normal up through frame 14, which is a READDIRPLUS
> > reply.  Then the server resends the reply after .2s, and and the
> > client resends its call shortly thereafter (but without acking the
> > latest reply).  And then the rest of the trace is resends of the
> > reply.
> > 
> > So it looks like the client stopped ACKing the server's replies?
> > 
> > You may also have filtered out some TCP ACKs, which makes this harder
> > to work out.
> 
> Ah yes, my bad, one TCP ACK was filtered out. Here I've kept trafic
> between the two machines but ssh.

Huh, no idea.  You can see the server retransmitting the readdir plus
reply, and still no ACKs from the client.

> Here I was capturing from the server, maybe I should try capturing on
> the client side?

Sure, maybe.

Honestly looks like a network problem, if it weren't for the failing on
the filesystem operation each time.

Hm, it may just be the first packet of a certain size.  In fact it's the
first frame > 1500 bytes in that trace.  Is there some problem with
jumbo frame configuration on your network?

--b.
