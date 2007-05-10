From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs issue with 2.6 kernel and busybox on arm
Date: Thu, 10 May 2007 12:15:40 -0400
Message-ID: <EXNANE01FRaqbC8wSA1000009b5@exnane01.hq.netapp.com>
References: <438397970705081016l5f25232ake8f37514395581fc@mail.gmail.com> <438397970705081016l5f25232ake8f37514395581fc@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Kallol Biswas" <nucleodyne@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HmBJS-0001wd-VX
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 09:16:19 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HmBJV-0007nw-KP
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 09:16:21 -0700
In-Reply-To: <438397970705081016l5f25232ake8f37514395581fc@mail.gmail.co
 m>
References: <438397970705081016l5f25232ake8f37514395581fc@mail.gmail.com>
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

At 01:16 PM 5/8/2007, Kallol Biswas wrote:
>Hi,
>   I have been having  problem with NFS on an embedded board.
>
>The board is a arm 920t based Centaur board, with 4MB flash and 32MB ram, running 2.6.9 kernel.

What toolset are you using to compile the kernel, and are you
using any eabi, thumb or other flags? I have had a number of
issues building 2.6.x for embedded ARMs that I could sometimes
work around, sometimes not. For instance there was a construct
in XFS that just plain wouldn't yield good code, I had to mangle a
few ?: operators before it stopped corrupting directories. I used
both the Codesourcery binaries and I also built gcc from the
OpenEmbedded patches.

Still, I don't recall having any issues with the NFS client. This
was mostly building .18, .19 and .20 though.

Tom. 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
