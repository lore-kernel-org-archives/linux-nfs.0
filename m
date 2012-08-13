Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53633 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab2HMR2d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Aug 2012 13:28:33 -0400
Date: Mon, 13 Aug 2012 13:28:30 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Vanns <james.vanns@framestore.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Your comments, guidance, advice please :)
Message-ID: <20120813172830.GA3803@fieldses.org>
References: <1344869728.8400.46.camel@sys367.ldn.framestore.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA939D69C@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA939D69C@SACEXCMBX04-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 13, 2012 at 04:40:39PM +0000, Myklebust, Trond wrote:
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
> 
> Otherwise, your strategy should in principle be OK, but with the caveat
> that a hash does not suffice to completely prevent collisions even if it
> is well chosen.
> IOW: All you are doing is tweaking the probability of a collision.

Also: the v4 rfc's allow two distinct filehandles to point to the same
file, don't they?  (See e.g.
http://tools.ietf.org/html/rfc5661#section-10.3.4).

--b.
