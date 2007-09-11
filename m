From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd
	and rework gssd and idmapd to use the new xlog logging
	infrastructure.
Date: Tue, 11 Sep 2007 11:28:48 -0400
Message-ID: <4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV7fQ-000575-U9
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:28:45 -0700
Received: from rv-out-0910.google.com ([209.85.198.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IV7fV-0005v3-EI
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:28:49 -0700
Received: by rv-out-0910.google.com with SMTP id g11so4647394rvb
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 08:28:48 -0700 (PDT)
In-Reply-To: <4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 9/11/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > Could you point me to the second in gssd that is doing this? It might be
> > better to use the print statements in a saner way.
> >
> > Dave
>
> Agreed.  The cuprit is print_hexl() in svcgssd_proc.c, which currently
> calls printerr() multiple times.  I'll look to see if I can find other
> instances that might be depending on the line acculation of printerr.

The qword_* functions in cachio.c also currently use this.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
