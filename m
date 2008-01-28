From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Sun, 27 Jan 2008 23:37:59 -0500
Message-ID: <200801280437.m0S4bxcE001453@agora.fsl.cs.sunysb.edu>
References: <20080122164111.GA24697@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, Trond.Myklebust@netapp.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45551 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbYA1Ei2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Jan 2008 23:38:28 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JJLlI-0001FR-7G
	for linux-nfs@vger.kernel.org; Mon, 28 Jan 2008 15:38:24 +1100
In-reply-to: Your message of "Tue, 22 Jan 2008 11:41:11 EST."
	<20080122164111.GA24697@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20080122164111.GA24697@fieldses.org>, "J. Bruce Fields" writes:
> On Mon, Jan 21, 2008 at 05:08:28PM -0500, bfields wrote:
> > On Mon, Jan 21, 2008 at 03:28:51PM -0500, Erez Zadok wrote:
> > > 
> > > Here you go.  See the tcpdump in here:
> > > 
> > > 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/
> > > 
> > > I captured it on an x86_64 machine using
> > > 
> > > 	tcpdump -s 0 -i lo -w tcpdump2
> > > 
> > > And it shows near the very end the ESTALE error.
> > 
> > Yep, thanks!  So frame 107855 has the MNT reply that returns the
> > filehandle in question, which is used in an ACCESS call in frame 107855
> > that gets an ESTALE.  Looks like an unhappy server!
> > 
> > > Do you think this could be related to nfs-utils?  I find that I can easily
> > > trigger this problem on an FC7 machine with nfs-utils-1.1.0-4.fc7 (within
> > > 10-30 runs of the above loop); but so far I cannot trigger the problem on an
> > > FC6 machine with nfs-utils-1.0.10-14.fc6 (even after 300+ runs of the above
> > > loop).
> > 
> > Yes, it's quite likely, though on a quick skim through the git logs I
> > don't see an obviously related commit...
> 
> It might help to turn on rpc cache debugging:
> 
> 	echo 2048 >/proc/sys/sunrpc/rpc_debug
> 
> and then capture the contents of the /proc/net/rpc/*/content files just
> after the failure.
> 
> Possibly even better, though it'll produce a lot of stuff:
> 
> 	strace -p `pidof rpc.mountd` -s4096 -otmp
> 
> and then pass along "tmp".

You can find both an strace and content files in

	http://agora.fsl.cs.sunysb.edu/tmp/nfs/

> And then of course if the regression is in nfs-utils then there's always
> a git-bisect as the debugging tool of last-resort: assuming you can
> reproduce the same regression between nfs-utils-1-0-10 and
> nfs-utils-1-1-0 from git://linux-nfs.org/nfs-utils, then all you'd need
> to do is clone that repo and do
> 
> 	git bisect start
> 	git bisect good nfs-utils-1-0-10
> 	git bisect bad nfs-utils-1-1-0
> 
> And it shouldn't take more than 8 tries.
> 
> Sorry for not having any more clever suggestions....
> 
> --b.

I tried to bisect nfs-utils but it didn't work.  First, the latest version
of nfs-utils didn't configure for me.  It complained

	Unable to locate information required to use librpcsecgss.  If you
      have pkgconfig installed, you might try setting environment variable
      PKG_CONFIG_PATH to /usr/local/lib/pkgconfig

The above appears to be an error if you don't have librpcsecgss API >=
0.10.  But mine, on FC7. is 0.11.  (I'm using a vanilla FC7.)

So I ran configure --disable-gss and was finally able to build the utils.
But then, I was having mount.nfs hanging often; stracing it revealed that
mount(2) was getting EACESS as if the dir wasn't exported (but exportfs said
it was).  I don't know if disabling gss at configure time could have
resulted in these hangs.

I continued and tried a few more intermediate versions in the bisection, and
several of them failed to compile and/or configure and/or autogen.sh.

So I don't know what else I can do; this bug may have to be fixed the hard
way.  (BTW, I can get you a self contained VMware image that'll show the
bug, if you'd like.)

Cheers,
Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

