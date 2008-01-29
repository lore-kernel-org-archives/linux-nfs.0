From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 28 Jan 2008 20:08:19 -0500
Message-ID: <20080129010819.GD16785@fieldses.org>
References: <20080122164111.GA24697@fieldses.org> <200801280437.m0S4bxcE001453@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35147 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbYA2BI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 20:08:27 -0500
In-Reply-To: <200801280437.m0S4bxcE001453-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 27, 2008 at 11:37:59PM -0500, Erez Zadok wrote:
> In message <20080122164111.GA24697@fieldses.org>, "J. Bruce Fields" writes:
> > On Mon, Jan 21, 2008 at 05:08:28PM -0500, bfields wrote:
> > > On Mon, Jan 21, 2008 at 03:28:51PM -0500, Erez Zadok wrote:
> > > > 
> > > > Here you go.  See the tcpdump in here:
> > > > 
> > > > 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/
> > > > 
> > > > I captured it on an x86_64 machine using
> > > > 
> > > > 	tcpdump -s 0 -i lo -w tcpdump2
> > > > 
> > > > And it shows near the very end the ESTALE error.
> > > 
> > > Yep, thanks!  So frame 107855 has the MNT reply that returns the
> > > filehandle in question, which is used in an ACCESS call in frame 107855
> > > that gets an ESTALE.  Looks like an unhappy server!
> > > 
> > > > Do you think this could be related to nfs-utils?  I find that I can easily
> > > > trigger this problem on an FC7 machine with nfs-utils-1.1.0-4.fc7 (within
> > > > 10-30 runs of the above loop); but so far I cannot trigger the problem on an
> > > > FC6 machine with nfs-utils-1.0.10-14.fc6 (even after 300+ runs of the above
> > > > loop).
> > > 
> > > Yes, it's quite likely, though on a quick skim through the git logs I
> > > don't see an obviously related commit...
> > 
> > It might help to turn on rpc cache debugging:
> > 
> > 	echo 2048 >/proc/sys/sunrpc/rpc_debug
> > 
> > and then capture the contents of the /proc/net/rpc/*/content files just
> > after the failure.
> > 
> > Possibly even better, though it'll produce a lot of stuff:
> > 
> > 	strace -p `pidof rpc.mountd` -s4096 -otmp
> > 
> > and then pass along "tmp".
> 
> You can find both an strace and content files in
> 
> 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/

The "content" files are all empty.  That can't be right....

But anyway the strace does show a problem:  grepping for reads and
writes to fd 5, which (based on the traffic) must be
/proc/net/rpc/nfsd.fh/channel, what you see is the kernel repeatedly
asking whether the server has exported a filesystem with a given uuid
(the big hex blob) to localhost.localdomain.  And mountd responds with
an export each time:....

1295  read(5, "localhost.localdomain 6 \\x2527c026ed8b49b6a2138c0ef212af45\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x2527c026ed8b49b6a2138c0ef212af45 2147483647 /n/export/b5 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x4a5b1c28abc84cc3abd6e072738b2418\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x4a5b1c28abc84cc3abd6e072738b2418 2147483647 /n/export/b6 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x46177ac6944a41fda30a0cfb7adf0694\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x46177ac6944a41fda30a0cfb7adf0694 2147483647 /n/export/b0 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x040be43d3d2a4433979d321ac075f6e5\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x040be43d3d2a4433979d321ac075f6e5 2147483647 /n/export/b1 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\xeac197ca26b444eeaf67c1f6cd92c24b\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\xeac197ca26b444eeaf67c1f6cd92c24b 2147483647 /n/export/b2 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x8e07ea5612584a19ba209780971f3221\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x8e07ea5612584a19ba209780971f3221 2147483647 /n/export/b3 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\xa509393cc478496a9c0eec09681a5033\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\xa509393cc478496a9c0eec09681a5033 2147483647 /n/export/b4 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x46177ac6944a41fda30a0cfb7adf0694\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x46177ac6944a41fda30a0cfb7adf0694 2147483647 /n/export/b0 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x040be43d3d2a4433979d321ac075f6e5\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x040be43d3d2a4433979d321ac075f6e5 2147483647 /n/export/b1 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\xeac197ca26b444eeaf67c1f6cd92c24b\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\xeac197ca26b444eeaf67c1f6cd92c24b 2147483647 /n/export/b2 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x8e07ea5612584a19ba209780971f3221\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x8e07ea5612584a19ba209780971f3221 2147483647 /n/export/b3 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\xa509393cc478496a9c0eec09681a5033\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\xa509393cc478496a9c0eec09681a5033 2147483647 /n/export/b4 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\xb97fa10332784bd2848a979af256ec61\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\xb97fa10332784bd2848a979af256ec61 2147483647 /n/export/b5 \n", 84) = 84
1295  read(5, "localhost.localdomain 6 \\x27a0f76db3fe44198a82d6370c63383f\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x27a0f76db3fe44198a82d6370c63383f 2147483647 /n/export/b6 \n", 84) = 84

.... except the last:

1295  read(5, "localhost.localdomain 6 \\x46177ac6944a41fda30a0cfb7adf0694\n", 128) = 59
1295  write(5, "localhost.localdomain 6 \\x46177ac6944a41fda30a0cfb7adf0694 2147483647 \n", 71) = 71

Here suddenly it's claiming there is no such export, even though it
actually identified it as /n/export/b0 just above.

What this means is that "found" is false in the check:

	if (found)
		qword_print(f, found_path);

at the end of nfs-utils/utils/mountd/cache.c:nfsd_fh().  Note that we're
in the FSID_UUID16_INUM case (that's the "6" in the reads and writes
above.

Anyway, it's clearly a bug in mountd someplace.  Maybe in the blkid
library.  Maybe a comparison of the strace leading up to the two results
would yield something?

I'm out of steam....

--b.

> 
> > And then of course if the regression is in nfs-utils then there's always
> > a git-bisect as the debugging tool of last-resort: assuming you can
> > reproduce the same regression between nfs-utils-1-0-10 and
> > nfs-utils-1-1-0 from git://linux-nfs.org/nfs-utils, then all you'd need
> > to do is clone that repo and do
> > 
> > 	git bisect start
> > 	git bisect good nfs-utils-1-0-10
> > 	git bisect bad nfs-utils-1-1-0
> > 
> > And it shouldn't take more than 8 tries.
> > 
> > Sorry for not having any more clever suggestions....
> > 
> > --b.
> 
> I tried to bisect nfs-utils but it didn't work.  First, the latest version
> of nfs-utils didn't configure for me.  It complained
> 
> 	Unable to locate information required to use librpcsecgss.  If you
>       have pkgconfig installed, you might try setting environment variable
>       PKG_CONFIG_PATH to /usr/local/lib/pkgconfig
> 
> The above appears to be an error if you don't have librpcsecgss API >=
> 0.10.  But mine, on FC7. is 0.11.  (I'm using a vanilla FC7.)
> 
> So I ran configure --disable-gss and was finally able to build the utils.
> But then, I was having mount.nfs hanging often; stracing it revealed that
> mount(2) was getting EACESS as if the dir wasn't exported (but exportfs said
> it was).  I don't know if disabling gss at configure time could have
> resulted in these hangs.
> 
> I continued and tried a few more intermediate versions in the bisection, and
> several of them failed to compile and/or configure and/or autogen.sh.
> 
> So I don't know what else I can do; this bug may have to be fixed the hard
> way.  (BTW, I can get you a self contained VMware image that'll show the
> bug, if you'd like.)
> 
> Cheers,
> Erez.
