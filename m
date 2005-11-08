From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: oops in rpc_pipe_release
Date: Mon, 7 Nov 2005 19:10:06 -0500
Message-ID: <20051108001006.GK10618@fieldses.org>
References: <436FEB9B.3010007@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZH3y-0006el-WA
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 16:10:10 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZH3w-0002Wg-J0
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 16:10:10 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <436FEB9B.3010007@google.com>
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

On Mon, Nov 07, 2005 at 04:04:43PM -0800, Vince Busam wrote:
> I'm using NFS3 with kerberos authentication, and 25 hour tickets that
> refresh when unlocking the screensaver.  Over the weekend, it'll hang
> with one of the following stack traces.  Any ideas what could cause
> this?

Could you retry with Trond's latest NFS_ALL?

http://linux-nfs.org/Linux-2.6.x/2.6.14/linux-2.6.14-NFS_ALL.dif

--b.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
