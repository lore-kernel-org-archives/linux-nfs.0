From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: A unresponsive file system can hang all I/O in the system
	on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 01:27:18 -0700
Message-ID: <92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
	<1190962752.31636.15.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbBBt-0003sU-Bm
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 01:27:17 -0700
Received: from nz-out-0506.google.com ([64.233.162.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbBBv-0002eK-MF
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 01:27:22 -0700
Received: by nz-out-0506.google.com with SMTP id f1so6836377nzc
	for <nfs@lists.sourceforge.net>; Fri, 28 Sep 2007 01:27:19 -0700 (PDT)
In-Reply-To: <1190962752.31636.15.camel@twins>
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

Thanks.

The BDI dirty limits sounds like a good idea.

Is there already a patch for this, which I could try?

I believe it works like this,

Each BDI, will have a limit. If the dirty_thresh exceeds the limit,
all the I/O on the block device will be synchronous.

so, if I have sda & a NFS mount, the dirty limit can be different for
each of them.

I can set dirty limit for
 -  sda to be 90% and
 -  NFS mount to be 50%.

So, if the dirty limit is greater than 50%, NFS does synchronously,
but sda can work asynchronously, till dirty limit reaches 90%.

Thanks
--Chakri

On 9/27/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Thu, 2007-09-27 at 23:50 -0700, Andrew Morton wrote:
>
> > What we _don't_ want to happen is for other processes which are writing to
> > other, non-dead devices to get collaterally blocked.  We have patches which
> > might fix that queued for 2.6.24.  Peter?
>
> Nasty problem, don't do that :-)
>
> But yeah, with per BDI dirty limits we get stuck at whatever ratio that
> NFS server/mount (?) has - which could be 100%. Other processes will
> then work almost synchronously against their BDIs but it should work.
>
> [ They will lower the NFS-BDI's ratio, but some fancy clipping code will
>   limit the other BDIs their dirty limit to not exceed the total limit.
>   And with all these NFS pages stuck, that will still be nothing. ]
>
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
