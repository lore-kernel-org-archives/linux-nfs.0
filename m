From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: Problems with NFS while running SpecSFS with JFS filesystem and 2.6 kernel.
Date: Mon, 15 Dec 2003 08:21:43 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031215142143.GA3981@dbz.austin.ibm.com>
References: <20031210144011.GE708@dbz.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        shaggy@austin.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVtbb-0003D3-Js
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 06:21:51 -0800
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AVtbb-0008FT-Dg
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 06:21:51 -0800
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
In-Reply-To: <20031210144011.GE708@dbz.austin.ibm.com> (from jrsantos@austin.ibm.com on Wed, Dec 10, 2003 at 08:40:11 -0600)
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

On 12/10/03 08:40:11, Jose R. Santos wrote:
> The machine I'm using is an old p660 with 8 RS64-IV proc running at 750MHz.
> For IO, I am using 4 FAStT fiber-channel controllers and 8 fiber-channel 
> adapters.  Linux sees 56 disk in total and each disk is actually a RAID5 
> array of 5 disk.

I have manage to reproduce this on a more down-to-earth setup.  I am running
an old RS6k-170 box with one Power3-II chip running at 450MHz and 1Gb RAM. 
In this setup I'm only using two filesystem and the problem still shows up
just about when I'm running out of free pages on the server.

Can anybody provide me with some tips as to how to debug this a bit further?
Really want to figure out if this is a NFS bug or a JFS one.

Thanks

-JRS


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
