From: Olaf Kirch <okir@suse.de>
Subject: Re: limitations at 5,8 GB?
Date: Thu, 1 Jan 2004 19:46:29 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040101184629.GB12146@suse.de>
References: <200312251945.42382.nuway@gmx.net> <news2mail-bsu6gq$rfj$1@cartman.spoiled.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Ac7q5-0003P2-1k
	for nfs@lists.sourceforge.net; Thu, 01 Jan 2004 10:46:33 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Ac7q4-0007IE-IN
	for nfs@lists.sourceforge.net; Thu, 01 Jan 2004 10:46:32 -0800
To: Juri Haberland <juri@koschikode.com>
In-Reply-To: <news2mail-bsu6gq$rfj$1@cartman.spoiled.org>
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

On Wed, Dec 31, 2003 at 09:56:42AM +0000, Juri Haberland wrote:
> This what I get from 'df' on one of my clients:
> ...
> nfs:/export/data     160066688 150683400   9383288  95% /net/data
> ...
> 
> You can see that I can access an exported disk with the size of 160GB.

I remember there was an integer overflow in the NFS statfs implementation
some 2.4 kernels that caused df to report silly disk sizes if the kernel
picked the wrong block size.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
