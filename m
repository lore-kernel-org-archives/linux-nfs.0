From: James Pearson <james-p@moving-picture.com>
Subject: Re: try tcp first; then udp
Date: Mon, 03 Nov 2003 12:01:22 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FA64392.43CE8D@moving-picture.com>
References: <1067700887.5055.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGdOm-00033m-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Nov 2003 04:01:32 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AGdOl-0005hw-Gt
	for nfs@lists.sourceforge.net; Mon, 03 Nov 2003 04:01:31 -0800
To: Oren Held <oren@held.org.il>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I asked this question a little why ago - Trond Myklebust has a patch
that does lots of other things, but can be easily modified to try tcp
first, then udp (by default his patch does udp first) see:

http://marc.theaimsgroup.com/?l=linux-nfs&m=105111029228592&w=2

I had to make a couple of other changes to the patch to get it to
compile with the RedHat version of the mount (util-linux) source RPM I'm
using - I've put my modified patch at:

ftp://ftp.moving-picture/private/james/util-linux-2.11n-tcpmount.patch.gz

I also had a minor problem on older RH7.1 machines that also need the
following patch:

ftp://ftp.moving-picture/private/james/util-linux-2.11n-cbuf.patch.gz

I've been using this modified mount for a few months without problems.

James Pearson

Oren Held wrote:
> 
> Hi,
> 
> I wonder if there's a way to mount an nfs share without specifying tcp
> or udp mount. I think that this is how Solaris behaves: it tries first
> tcp, if it's not good, then it tries udp.
> 
> I've been looking for such a mount option and found none; I think it can
> be really useful when one has hetrogenous nfs servers (some use tcp,
> some use udp) - in the case I just want it to work and don't care which
> protocol it'll use.
> 
> Is there a way to do it with the current kernel/mount versions?
> 
> 10x
> 
>  - Oren
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback Program.
> Does SourceForge.net help you be more productive?  Does it
> help you create better code?   SHARE THE LOVE, and help us help
> YOU!  Click Here: http://sourceforge.net/donate/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
