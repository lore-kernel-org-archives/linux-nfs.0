From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3 UID/GID mapping
Date: Fri, 23 Apr 2004 14:23:22 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040423182322.GD18366@fieldses.org>
References: <m3vfjsxsky.fsf@pc213.belcaf.minsk.by> <20040422172512.GE12400@fieldses.org> <m3ekqfvz16.fsf@pc213.belcaf.minsk.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH5Kl-0008OI-Rd
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 11:23:31 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BH5Kl-0006nG-FA
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 11:23:31 -0700
To: "Ed V. Bartosh" <ed@sam-solutions.net>
In-Reply-To: <m3ekqfvz16.fsf@pc213.belcaf.minsk.by>
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

On Fri, Apr 23, 2004 at 12:12:05PM +0300, Ed V. Bartosh wrote:
> It's just a server-side mapping. I think we don't need to rely on
> client for that. There are many other possibilities to change uids on
> client side.

The situation where I can imagine it being useful is when you had a
client (maybe a laptop) that you wanted to be able to access shares on
servers in different uid domains (possibly simultaneously).

> Also client-based solution is less secure than server-side one and
> also it's the linux-only solution.

I don't see the argument there.

> I think there are many other situations when it may be useful to use
> this kind of mapping.

Sure.  I think someone on the linux kernel mailing list said they wanted
to able to squash ranges of uid's.

> > Do you also need to do map the id's in nfs3xdr.c:xdr_encode_setattr() and
> > xdr_decode_fattr()?
> Yes, I do. Thank you.

That means you need a second mapping: in addition to mapping remove
clients' id's to local server id's, you need the inverse mapping from
local id's to the clients' id's (to get ls right).

> > We need to figure out a way to do this without duplicating so much code
> > from nfs4idmap.c.
> Yes, we need it, but it's not too much code. I think that there is
> sense to move only deferred request handling functions somewhere in
> separate file and use it from nfs4 and nfs3 idmap functions.

OK.

> BTW, Is any chance for this functionality to be in mainstream sometime ?

It seems useful, but it's not really up to me.

--Bruce Fields


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
