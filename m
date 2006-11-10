From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Fri, 10 Nov 2006 15:11:31 -0500
Message-ID: <4d569c330611101211y4846d2b2l2ad4be385688deff@mail.gmail.com>
References: <20061103123737.GA5199@uio.no>
	<20061106231539.GI12372@fieldses.org> <20061106231615.GA17582@uio.no>
	<20061106231821.GK12372@fieldses.org>
	<20061106232224.GL12372@fieldses.org> <20061106234607.GA18236@uio.no>
	<20061106234922.GM12372@fieldses.org> <20061107004720.GA16731@uio.no>
	<20061108004440.GL11346@fieldses.org> <20061108005045.GA4524@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gicj0-0003lT-97
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 12:11:42 -0800
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Giciz-0005pP-5Q
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 12:11:43 -0800
Received: by ug-out-1314.google.com with SMTP id z38so630853ugc
	for <nfs@lists.sourceforge.net>; Fri, 10 Nov 2006 12:11:37 -0800 (PST)
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20061108005045.GA4524@uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 11/7/06, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> On Tue, Nov 07, 2006 at 07:44:40PM -0500, J. Bruce Fields wrote:
> >>>> http://home.samfundet.no/~sesse/svcgssd-strace.log.bz2
> >>> 18:48:39 ERROR 404: Not Found.
> >> Hm, that's odd. Oh well, I found a log here now, at least -- try it now.
> > Nope.  Are you sure there isn't a typo in the URL?  I'm just
> > cut-n-pasting it.
>
> Gah! It's not my day today. Try once more, please.

I didn't find any clues in the strace output either.  I'm not sure
where to look next.

K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
