From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils 1.0.8 build failure
Date: Thu, 13 Apr 2006 11:51:52 -0400
Message-ID: <20060413155152.GA29358@fieldses.org>
References: <1144915146.32160.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FU46v-0006NP-2D
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 08:51:57 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FU46u-0005di-RO
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 08:51:57 -0700
To: Andrew Zhukov <zhukov@tst.spb.su>
In-Reply-To: <1144915146.32160.26.camel@localhost.localdomain>
Sender: nfs-admin@lists.sourceforge.net
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

On Thu, Apr 13, 2006 at 10:59:06AM +0300, Andrew Zhukov wrote:
> I tried to build fine "mount" for "mount -t nfs". I mean the one which
> wouldn't complain "mount is older/newer than the kernel"...
> 
> First I tried to build it on x86 RedHat 9.
> 
> 1. ./configure without restriction won't work... I have to use: 
> 
> ./configure --build=arm-linux-uclibc --enable-nfsv4=no --enable-nfsv3=no
> --enable-gss=no
> 
> 2. make fails:
> 
> ...
> Making all in include
> make[2]: Entering directory `/tmp/nfs-utils-1.0.8/support/include'

Note that nfs-utils doesn't provide the nfs "mount" program.  You want
util-linux for that.  And those mount version complaints can be safely
ignored anyway.

The kernel oopses in nfs_lookup are a separate issue, I don't know
what's causing those.  So you're building in an nfs-mounted directory on
a client with a 2.6.10 kernel?  Could you try a more recent kernel?

--b.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
