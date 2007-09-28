From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: A unresponsive file system can hang all I/O in the system
	on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 02:20:28 -0700
Message-ID: <92cbf19b0709280220o7cdd4b1cua37a8776af68ac25@mail.gmail.com>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
	<1190962752.31636.15.camel@twins>
	<92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
	<1190968800.31636.26.camel@twins>
	<92cbf19b0709280201o3778f945mf1d8d61cbb3d0558@mail.gmail.com>
	<1190970729.31636.29.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbC1I-0000tW-Ej
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 02:20:24 -0700
Received: from wa-out-1112.google.com ([209.85.146.180])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbC1N-0004RZ-DJ
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 02:20:29 -0700
Received: by wa-out-1112.google.com with SMTP id k22so4451241waf
	for <nfs@lists.sourceforge.net>; Fri, 28 Sep 2007 02:20:29 -0700 (PDT)
In-Reply-To: <1190970729.31636.29.camel@twins>
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

It's 2.6.23-rc6.

Thanks
--Chakri

On 9/28/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Fri, 2007-09-28 at 02:01 -0700, Chakri n wrote:
> > Thanks for explaining the adaptive logic.
> >
> > > However other devices will at that moment try to maintain a limit of 0,
> > > which ends up being similar to a sync mount.
> > >
> > > So they'll not get stuck, but they will be slow.
> > >
> > >
> >
> > Sync should be ok, when the situation is bad like this and some one
> > hijacked all the buffers.
> >
> > But, I see my simple dd to write 10blocks on local disk never
> > completes even after 10 minutes.
> >
> > [root@h46 ~]# dd if=/dev/zero of=/tmp/x count=10
> >
> > I think the process is completely stuck and is not progressing at all.
> >
> > Is something going wrong in the calculations where it does not fall
> > back to sync mode.
>
> What kernel is that?
>
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
