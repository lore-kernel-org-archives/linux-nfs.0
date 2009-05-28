From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: 2.6.29+ NFS-Server Problem "reconnect_path: npd != pd"
Date: Thu, 28 May 2009 22:32:28 +0200
Message-ID: <20090528203228.GA6056@geggus.net>
References: <20090521142026.GA5566@geggus.net> <1242924599.6687.1.camel@heimdal.trondhjem.org> <20090521165751.GA4428@geggus.net> <1242927133.6687.4.camel@heimdal.trondhjem.org> <gv4463$6fn$1@ultimate100.geggus.net> <1242929546.22947.11.camel@heimdal.trondhjem.org> <20090528202803.GF13860@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764248AbZE1Ucj@vger.kernel.org>
In-Reply-To: <20090528202803.GF13860@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Donnerstag, den 28. Mai um 22:28 Uhr:

> Looks like you have subtree_check set on the "bad" export, and
> no_subtree_check set on the "good" export.  subtree_check can result in
> spurious stale errors when files are renamed, so it's possible this is
> by design.
> 
> You say you get that message on 296.29.x but not 2.6.27.x.

Exactly! http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=527517
may refer the same bug.

> And you say you also get stale filehandle errors.

Only on 2.6.29.x. Everything works fine qwith the older Kernel.

>  I assume you didn't get the same stale filehandle errors on 2.6.27.x?

No errors on the older Kernel.

Sven

-- 
"In my opinion MS is a lot better at making money than it is at making good
operating systems" (Linus Torvalds, August 1997)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
