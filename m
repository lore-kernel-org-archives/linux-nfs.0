From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs-utils-1.0.5 is not backwards compatible with 2.4
Date: Mon, 4 Aug 2003 10:55:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16173.44816.973033.11872@gargle.gargle.HOWL>
References: <3F294DE3.9020304@RedHat.com>
	<16169.54918.472349.928145@gargle.gargle.HOWL>
	<20030801143807.GB24358@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
    nfs@lists.sourceforge.net,
    linux-kernel <linux-kernel@vger.kernel.org>,
    Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jTdh-00016U-00
	for <nfs@lists.sourceforge.net>; Sun, 03 Aug 2003 17:55:54 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <SteveD@redhat.com>)
	(for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) (for <akpm@osdl.org>) By note
	With Smtp ; Mon, 4 Aug 2003 10:55:45 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Friday August 1
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday August 1, chip@pobox.com wrote:
> According to Neil Brown:
> > I don't know if there is any such code, but if there is I apoligize for
> > breaking it and suggest that the best fix is to not use the header
> > file it was using but it explicitly include the values for NFSEXP_* in
> > that code.
> 
> The only really bad thing about the current situation is that the name
> "NFSEXP_CROSSMNT" is poisoned by having had two historical
> definitions.  So it that name should be dropped, IMO, and replaced by
> something textually different.  "NFSEXP_XMOUNT", perhaps.  Even
> "NFSEXP_CROSSMNT2" would work.  Just as long as code that said
> "CROSSMNT" to mean "NOHIDE" wouldn't accidentally get CROSSMNT instead.

If we were to change it,  I would prefer  NFSEXP_CROSSMOUNT.

I might send such a patch to Linus and update nfs-utils if/when it
gets included (or should 2.6 patches start going to Andrew now??)

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
