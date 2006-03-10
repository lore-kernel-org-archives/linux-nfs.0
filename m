From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: /var/lib/nfs/v4recovery
Date: Fri, 10 Mar 2006 10:28:09 -0500
Message-ID: <20060310152809.GE24554@fieldses.org>
References: <20060310071803.8229.qmail@web51601.mail.yahoo.com> <20060310074411.78426.qmail@web51612.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHjXH-0003MR-J8
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 07:28:11 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHjXH-0004ey-5K
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 07:28:11 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060310074411.78426.qmail@web51612.mail.yahoo.com>
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

On Thu, Mar 09, 2006 at 11:44:11PM -0800, mehta kiran wrote:
> Hi,
>    I could see that it is mentioned that
>    /var/lib/nfs/v4recovery needs to be created
>    for NFSv4 at 
>  
> http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html.
>    1. What is this file for ?
>       As NFSv4 uses lease based locking , it does
> "NOT"
>       create files on persistent storage.

It does need some persistent storage--see rfc3530 section 8.6.3.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
