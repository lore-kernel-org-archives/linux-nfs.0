From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: bad cookie size 20 (only cookies under 8 bytes are supported.)
Date: Sun, 02 Nov 2003 18:22:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FA53D63.7010603@inf.ethz.ch>
References: <3FA512B2.1080109@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGLvb-0005Go-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Nov 2003 09:22:15 -0800
Received: from mxout.hispeed.ch ([62.2.95.247] helo=smtp.hispeed.ch)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AGLva-0001HJ-UR
	for nfs@lists.sourceforge.net; Sun, 02 Nov 2003 09:22:15 -0800
Received: from inf.ethz.ch (dclient217-162-175-109.hispeed.ch [217.162.175.109])
	by smtp.hispeed.ch (8.12.6/8.12.6/tornado-1.0) with ESMTP id hA2HMCoO005859
	for <nfs@lists.sourceforge.net>; Sun, 2 Nov 2003 18:22:12 +0100
In-Reply-To: <3FA512B2.1080109@inf.ethz.ch>
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

Just wanted to add:
On the same token, I did have to move the exported files to a different 
partition. Before I did that, I asked all users to log out everywhere, 
so that no homes are mounted before I started moving the files. Could it 
be that this errors come from clients that try to lock "old" inodes?

Marc Schmitt wrote:

> Hi all,
>
> I did upgrade yesterday my RedHat 7.3 box (2.4.20-20.7smp) from 
> nfs-utils 1.0.5 to 1.0.6, after that, messages was full with:
>
> Nov  2 15:02:56 server kernel: lockd: bad cookie size 20 (only cookies 
> under 8 bytes are supported.)
> Nov  2 15:02:56 server kernel: svc: failed to decode args
> Nov  2 15:02:57 server kernel: lockd: bad cookie size 20 (only cookies 
> under 8 bytes are supported.)
> Nov  2 15:02:57 server kernel: svc: failed to decode args
> Nov  2 15:03:16 server kernel: lockd: bad cookie size 20 (only cookies 
> under 8 bytes are supported.)




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
