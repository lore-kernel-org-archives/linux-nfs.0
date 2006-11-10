From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Fri, 10 Nov 2006 16:37:32 -0500
Message-ID: <4d569c330611101337g6f7bfd3ex2e6d347d5b030e98@mail.gmail.com>
References: <20061106231821.GK12372@fieldses.org>
	<20061106234607.GA18236@uio.no> <20061106234922.GM12372@fieldses.org>
	<20061107004720.GA16731@uio.no> <20061108004440.GL11346@fieldses.org>
	<20061108005045.GA4524@uio.no>
	<4d569c330611101211y4846d2b2l2ad4be385688deff@mail.gmail.com>
	<20061110202521.GE9453@fieldses.org>
	<4d569c330611101239v46a8e444u15aa06433259d220@mail.gmail.com>
	<20061110204917.GF9453@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gie45-0003YF-1B
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 13:37:33 -0800
Received: from ug-out-1314.google.com ([66.249.92.169])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gie45-0003RF-RN
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 13:37:34 -0800
Received: by ug-out-1314.google.com with SMTP id z38so651078ugc
	for <nfs@lists.sourceforge.net>; Fri, 10 Nov 2006 13:37:33 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061110204917.GF9453@fieldses.org>
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
> On Fri, Nov 10, 2006 at 03:39:44PM -0500, Kevin Coffman wrote:
> > On 11/10/06, J. Bruce Fields <bfields@fieldses.org> wrote:
> > >Well, if we're seeing a NO_CONTEXT error on the wire, and if (as is
> > >apparent from the strace), svcgssd isn't itself sending a NO_CONTEXT
> > >error down, then you must be correct that it's coming from
> > >gss_write_init_verf().
> > >
> > >So gss_svc_searchbyctx() is returning NULL.
> > >
> > >I wonder if the kmalloc() in dup_to_netobj() is failing?  If it was
> > >caused by a memory leak of some kind, that would explain why it takes a
> > >while for the problem to show up, but not why restarting rpc.svcgssd
> > >would help.
> >
> > That is the part that is most confusing to me.  Dumb question time: Is
> > kernel memory allocated by the kernel while running in the svcgssd
> > task freed up when that task is restarted?
>
> No, kmalloc() allocations belong to the kernel, not to any particular
> process.
>
> So it's a little hard to tell how the server auth_gss kernel code can
> even be affected by svcgssd restarting.  Just one obvious thing: svcgssd
> holds /proc/net/rpc/auth.rpcsec.init/channel open, so when it's
> restarted, there will be a close and then an open of that file.

svcgssd actually fopens and fcloses the context channel and opens and
closes the init channel for each downcall.  So I don't see how that
would affect it either?

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
