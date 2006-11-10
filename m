From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Fri, 10 Nov 2006 15:39:44 -0500
Message-ID: <4d569c330611101239v46a8e444u15aa06433259d220@mail.gmail.com>
References: <20061106231539.GI12372@fieldses.org>
	<20061106231821.GK12372@fieldses.org>
	<20061106232224.GL12372@fieldses.org> <20061106234607.GA18236@uio.no>
	<20061106234922.GM12372@fieldses.org> <20061107004720.GA16731@uio.no>
	<20061108004440.GL11346@fieldses.org> <20061108005045.GA4524@uio.no>
	<4d569c330611101211y4846d2b2l2ad4be385688deff@mail.gmail.com>
	<20061110202521.GE9453@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GidAB-0006QC-9w
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 12:39:47 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GidAB-0003ik-97
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 12:39:48 -0800
Received: by ug-out-1314.google.com with SMTP id z38so637430ugc
	for <nfs@lists.sourceforge.net>; Fri, 10 Nov 2006 12:39:46 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061110202521.GE9453@fieldses.org>
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

On 11/10/06, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Nov 10, 2006 at 03:11:31PM -0500, Kevin Coffman wrote:
> > I didn't find any clues in the strace output either.  I'm not sure
> > where to look next.
>
> Well, if we're seeing a NO_CONTEXT error on the wire, and if (as is
> apparent from the strace), svcgssd isn't itself sending a NO_CONTEXT
> error down, then you must be correct that it's coming from
> gss_write_init_verf().
>
> So gss_svc_searchbyctx() is returning NULL.
>
> I wonder if the kmalloc() in dup_to_netobj() is failing?  If it was
> caused by a memory leak of some kind, that would explain why it takes a
> while for the problem to show up, but not why restarting rpc.svcgssd
> would help.

That is the part that is most confusing to me.  Dumb question time: Is
kernel memory allocated by the kernel while running in the svcgssd
task freed up when that task is restarted?

K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
