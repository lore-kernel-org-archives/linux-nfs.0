From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Makefile system
Date: Mon, 12 Jul 2004 19:59:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040712235920.GA27936@fieldses.org>
References: <20040623080942.GJ21651@pengutronix.de> <20040708153346.342C512FF4@citi.umich.edu> <20040708172034.GM22328@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Coffman <kwc@citi.umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkAhd-0006tm-CE
	for nfs@lists.sourceforge.net; Mon, 12 Jul 2004 16:59:21 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BkAhc-0003ht-U6
	for nfs@lists.sourceforge.net; Mon, 12 Jul 2004 16:59:21 -0700
To: Robert Schwebel <robert@schwebel.de>
In-Reply-To: <20040708172034.GM22328@pengutronix.de>
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

On Thu, Jul 08, 2004 at 07:20:34PM +0200, Robert Schwebel wrote:
> On Thu, Jul 08, 2004 at 11:33:46AM -0400, Kevin Coffman wrote:
> > Use of the autotools would simplify CITI's patches for NFSv4.  Is it 
> > likely these autotools changes will be incorporated into the package 
> > such that we could take advantage of them?
> 
> I'm not sure if anybody had time to review our changes yet, there was no
> real feedback from the community. 
> 
> If we should change the patches to make them better integratable just
> drop me a note. 

Could you make actual patches instead of tarballs?  (Or did I miss the
patches?)

I downloaded one of the tarballs and tried doing that myself--after
excluding automatically generated files (Makefile.in, Makefile,
aclocal.m4, compile, config.guess, config.h.in, config.sub, configure,
etc....) it was down to less than a tenth the original diff, but there
seemed to be some unrelated changes in there (e.g., some random text
files (like utils/nhfsstone/DISCLAIMER) diseappeared), and I gave up.

So, making patches would help, as would anything you could do to pare
the patches down to the minimum necessary so that we could understand
what's being changed.

--b.


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
