Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58673 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753234AbbHGPTh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2015 11:19:37 -0400
Date: Fri, 7 Aug 2015 11:19:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: grace-period ending & NLM
Message-ID: <20150807151936.GC15313@fieldses.org>
References: <20150806202336.GA7235@fieldses.org>
 <20150806182442.13f19d7e@tlielax.poochiereds.net>
 <20150807010234.GA8747@fieldses.org>
 <20150807071058.689d83e9@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150807071058.689d83e9@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 07, 2015 at 07:10:58AM -0400, Jeff Layton wrote:
> On Thu, 6 Aug 2015 21:02:34 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Aug 06, 2015 at 06:24:42PM -0400, Jeff Layton wrote:
> > > On Thu, 6 Aug 2015 16:23:36 -0400
> > > bfields@fieldses.org (J. Bruce Fields) wrote:
> > > 
> > > > We have two grace periods, one for NLM and one for NFSv4+, and don't
> > > > permit normal locking until both are over.
> > > > 
> > > > As far as I can tell nfsdcltrack doesn't understand statd/NSM state; it
> > > > only concerns itself with NFSv4+.  It can end the NFSv4 grace period
> > > > early, but that still leaves the server returning GRACE errors until NSM
> > > > exits its grace period.
> > > > 
> > > > The server has never had any smarts to end the NSM grace period early,
> > > > even though there are common cases (e.g., no clients at all) where it
> > > > easily could.  We could fix that.
> > > > 
> > > 
> > > Erm...but it does have those smarts. statd should end the grace period
> > > early if there were no clients to be notified when it starts. That's
> > > done by writing to /proc/fs/lockd/nlm_end_grace. Those patches were
> > > merged upstream in the kernel and nfs-utils around the same time as the
> > > other early grace lifting patches.
> > 
> > Yeah, I don't know how I forgot that.  Thanks for the reminder.  That
> > doesn't seem to be working for me on Fedora 21.  I'll take another look.
> > 
> > (I may still apply ths patch if you don't see a problem with it.)
> > 
> > --b.
> > 
> 
> No objection. I think it looks reasonable.
> 
> I'd also be interested to know why the NLM grace period isn't being
> lifted early for you. That did work when I tested it last.
> 
> Oh, and I misstated earlier...it's not statd that lifts the grace
> period early, it's sm-notify. sm-notify is in charge of notifying hosts
> after a reboot and if it has none to notify it'll write "Y" to that file
> (if it exists).

Yes, sorry, and I just wasn't running the test right: sm-notify only
gets run on a real reboot.  (nfs-server.service does start it, but it
exits immediately if it sees the pid file it wrote before).  Adding
SMNOTIFYARGS='-f' to /etc/sysconfig/nfs makes this work as expected.

(In my defense, that's kind of weird behavior: but as I understand it
statd lumps together all clients and servers on the same machine, so a
a notify would cause us to lose locks on any nfs mounts?  In which case
maybe this is the only safe thing to do.)

--b.
