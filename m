From: Chip Salzenberg <chip@pobox.com>
Subject: Re: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Sun, 5 Dec 2004 21:02:39 -0500
Message-ID: <20041206020239.GI6146@perlsupport.com>
References: <20041204221504.GD6146@perlsupport.com> <16819.43303.95619.661063@cse.unsw.edu.au> <20041206004557.GA14863@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb8Dq-0006Ic-Hl
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 18:03:30 -0800
Received: from perlsupport.com
	([66.220.6.226] helo=mail.perlsupport.com ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Cb8Dm-0002Jd-Ew
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 18:03:28 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041206004557.GA14863@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

As it happens this is important but not urgent.  Joey Schulze says
that the right thing to do for the security hole is upload the
minimally changed version.  Then we can get around to the head version
with its new features, dependencies, and packages.

According to J. Bruce Fields:
> I'm happy to maintain [nfsidmap] but need a debian developer to
> sponsor.

Sounds good.  I've never done a sponsorship but I suppose it can't be
too hard.

> I sent Chip a number of messages about this, and he was cc:'d on some
> messages about this to debian-mentors, so I'm a little suprised that
> this is news.  Chip, am I getting lost in some spam filter or something?

I've been putting off nfs-utils maintenance for somewhat too long (and
thus saving for later reading all messages on the subject); then this
security thing reared its head, and I went for the shortest path to a
new release.  I see some messages from you still unread; once the
minor release is out, I'll read them.
-- 
Chip Salzenberg              - a.k.a. -           <chip@pobox.com>
People are supposed to die for freedom.  Not the other way around.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
