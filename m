Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377Ab3KRR3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 12:29:05 -0500
Date: Mon, 18 Nov 2013 12:28:58 -0500
To: Albert Fluegel <af@muc.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131118172858.GE3203@fieldses.org>
References: <20131118124406.GA46678@colin.muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118124406.GA46678@colin.muc.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 01:44:06PM +0100, Albert Fluegel wrote:
> Hello,
> 
> i posted Bug 1028439 to bugzilla.redhat.com and was asked to post the patch
> to this mailing list for discussion and possibly upstream fix.
> 
> As most of the followers here probably do not have access to the redhat
> bugzilla, i'll repeat the most important parts of the report here. A proposed
> patch is attached. Sorry, this is not short, but it's not a simle topic
> 
> Description of problem:
> When a Solaris 2.5, 2.6, 7 or Solaris 8 client uses a Linux
> NFS (version 3) server, the directories are messed up over NFS,
> many files not found. As an example, GNU make 3.81 is tried to build.
> After the configure step running make the Makefile is not found.
> Some lines from truss showing an inconsistency:
> ...
> stat(".", 0xFFBEE628)                           = 0
> open64(".", O_RDONLY|O_NDELAY)                  = 3
> fcntl(3, F_SETFD, 0x00000001)                   = 0
> fstat64(3, 0xFFBEE4F8)                          = 0
> getdents64(3, 0x00054FE0, 1048)                 = 1024
> close(3)                                        = 0
> stat("GNUmakefile", 0xFFBEE708)                 Err#2 ENOENT
> stat("makefile", 0xFFBEE708)                    Err#2 ENOENT
> stat("Makefile", 0xFFBEE708)                    = 0
> makewrite(2, " m a k e", 4)                             = 4
> : *** write(2, " :   * * *  ", 6)                       = 6
> No targets specified and no makefile foundwrite(2, " N o   t a r g e t s   s".., 42)    = 42
> 
> prompt% ls Makefile
> Makefile
> 
> The problem does not show up with Linux or e.g. SunOS-4 NFS clients.
> 
> What i've seen on the network is, that the
> Linux NFS server replies among other things to a "Check access permission"
> the following:
> 
> NFS:    File type = 2 (Directory)
> NFS:    Mode = 040755
> 
> A netapp server replies here:
> NFS:    File type = 2 (Directory)
> NFS:    Mode = 0755
> 
> The RFC 1813 i read:
>    fattr3
> 
>       struct fattr3 {
>          ftype3     type;
>          mode3      mode;
>          uint32     nlink;
> ...
> For the mode bits only the lowest 9 are defined in the RFC
> 
> The problem occurs with the kernels 2.6.18-348.3.1.el5 upward for RHEL5,
> 2.6.32-358.18.1.el6 upward and some versions earlier and with Fedora kernel
> 3.9.10-100 on the NFS server
> 
> There seem to be several issues, all caused by the 64 bit cookies enabled,
> directly or indirectly.
> One change:
> diff -r kernel-2.6.18-308/linux-2.6.18-308.11.1.el5.i386/fs/nfsd/vfs.c kernel-2.6.18-348/linux-2.6.18-348.3.1.el5.i386/fs/nfsd/vfs.c
> 725a727,733
> > 	else {
> > 		if (may_flags & NFSD_MAY_64BIT_COOKIE)
> > 			(*filp)->f_mode |= FMODE_64BITHASH;
> > 		else
> > 			(*filp)->f_mode |= FMODE_32BITHASH;
> > 	}
> > 
> 
> makes bits set in the mode field of the
> RPC reply, that are used internally by the kernel.

It appears to me that you're just confused by the naming of the field;
"f_mode" has nothing to do with a file's mode bits.

Have you actually checked that turning off FMODE_64BITHASH changes the
returned mode bits?  If so, that would be interesting (and extremely
surprising).

> The other problem is, that the nfsd_readdir seems not to find cookies
> or at least does not position the read pointer correctly and starts
> reading the directory anew, causing the (Solaris) client to be in an
> endless loop. The cookie returned in a "Read Directory" reply is actually
> 32 bit and with the next query issued with this (identical) cookie
> the Linux NFS server replies with the directories started anew.
> I don't know, in how far the cookies depend on the client. However,
> with a Solaris client i consider it worth noting, that in the reply
> to the directory read the upper 32 bits are either all 0 or all 1
> (0xffffffff). With a Linux client, they are either 0 or have some
> random value, but not constantly 0xffffffff .

Apologies, I don't understand this description.  Best would be if you
could send a packet capture showing the described behavior.  (When you
say "in the reply to the directory read", you're referring to cookies in
the READDIR reply?  Those should be identical regardless of which client
requests them.)

> Regarding the cookie thing i don't think the clients misbehave.
> Linux clients seem to evaluate an entire reply to a "Read Directory" and
> use the cookie of the last received entry for the next query. Solaris in
> my test case with the unpacked GNU make 3.81 uses about 60% of the entries
> and puts the cookie of the next one into the next "Read Directory"
> NFS query to the server. As far as i can see in the wireshark evaluating
> the network trace, the cookie is 100 % correct, but the Linux NFS server
> starts with the beginning of the directory again in the next reply.
> Could be, all cookies except the last one of the query are actually
> unusable and the problem is not seen on a Linux NFS client, because it
> always takes the last cookie for the next query.

There was indeed a known RHEL-only bug which corrupted all but the final
cookie in a READDIR reply, fixed in RHEL5 kernel -353.  This should not
be reproduceable upstream.

--b.
