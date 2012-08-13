Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5.framestore.com ([193.203.83.15]:37643 "EHLO
	mx5.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab2HMQv7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 12:51:59 -0400
Subject: Re: Your comments, guidance, advice please :)
From: Jim Vanns <james.vanns@framestore.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Vanns <james.vanns@framestore.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA939D69C@SACEXCMBX04-PRD.hq.netapp.com>
References: <1344869728.8400.46.camel@sys367.ldn.framestore.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA939D69C@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 13 Aug 2012 17:51:48 +0100
Message-ID: <1344876708.8400.55.camel@sys367.ldn.framestore.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-08-13 at 16:40 +0000, Myklebust, Trond wrote:
> On Mon, 2012-08-13 at 15:55 +0100, Jim Vanns wrote:
> > Hello NFS hackers. First off, fear not - the attached patch is not
> > something I wish to submit to the mainline kernel! However, it is
> > important for me that you pass judgement or comment on it. It is small.
> > 
> > Basically, I've written the patch solely to workaround a Bluearc bug
> > where it duplicates fileids within an fsid and therefore we're not able
> > to rely on the fsid+fileid to identify distinct files in an NFS
> > filesystem. Some of our storage indexing and reporting software relies
> > on this and works happily with other, more RFC-adherent
> > implementations ;)
> > 
> > The functional change is one that modified the received fileid to a hash
> > of the file handle as that, thankfully, is still unique. As with a
> > fileid I need this hash to remain consistent for the lifetime of a file.
> > It is used as a unique identifier in a database.
> > 
> > I'd really appreciate it if you could let me know of any problems you
> > see with it - whether it'll break some client-side code, hash table use
> > or worse still send back bad data to the server.
> > 
> > I've modified what I can see as the least amount of code possible - and
> > my test VM is working happily as a client with this patch. It is
> > intended that the patch modifies only client-side code once the Bluearc
> > RPCs are pulled off the wire. I never want to send back these modified
> > fileids to the server.
> 
> READDIR and READDIRPLUS will continue to return the fileid from the
> server, so the getdents() and readdir() syscalls will be broken. Since
> READDIRPLUS does return the filehandle, you might be able to fix that
> up, but plain READDIR would appear to be unfixable.

Thanks, I'll take a look at that.

> Otherwise, your strategy should in principle be OK, but with the caveat
> that a hash does not suffice to completely prevent collisions even if it
> is well chosen.
> IOW: All you are doing is tweaking the probability of a collision.

Oh yes, I completely understand that. I've done very little testing but
I'm confident that this at least reduces the number of collisions
considerably.

Jim

> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> NrybXǧv^)޺{.n+{"^nrzh&Gh(階ݢj"mzޖfh~m

-- 
Jim Vanns
Systems Programmer
Framestore

