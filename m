Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:2502 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615Ab3JZLhO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Oct 2013 07:37:14 -0400
Date: Sat, 26 Oct 2013 07:36:52 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        linux-nfs@vger.kernel.org, Ric Wheeler <ricwheeler@gmail.com>,
        nfsv4 <nfsv4@ietf.org>
Message-ID: <786887171.10.1382787412438.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <20131026051815.GA10048@fieldses.org>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Thanks, Bruce.

----- "J. Bruce Fields" <bfields@fieldses.org> wrote:
attributes, e.g., perhaps update
> atomicity.
> 
> Right, xattrs are expected to be small-ish and are set and queried
> atomically.  A server that implements named attributes using xattrs
> has
> to for example implement write as a read-modify-write of the
> attribute.

Ok, helpful.

> You normally only address xattrs by name, so I guess you'd have to
> stick
> a hash of the name in the filehandle.

That's how we're (re) implementing it for G.

> 
> We could probably get *something* working, but I don't know whether
> the
> semantics would be close enough to not break an application that was
> written to a named-attribute api.

I agree, there seems to be a missing piece.

> 
> Personally what I'd like to see is a really thorough description of a
> use case or two.  All I've ever heard is either "selinux", or some
> vague
> ideas about things people think might be cool to try.

I think the Christoph have made the best case that can be made, but I have
nothing more for the Linux debate.  I'd like to see us solve the design 
problems, though.

Matt

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
