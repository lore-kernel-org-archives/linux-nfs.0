From: Peter Staubach <staubach@redhat.com>
Subject: Re: Rename window
Date: Fri, 11 Nov 2005 10:33:07 -0500
Message-ID: <4374B9B3.6030905@redhat.com>
References: <9E621559095AA746B22B21CD4FAF99A55735BC@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eaatx-00006Z-IV
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 07:33:17 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eaatw-0002UQ-2S
	for nfs@lists.sourceforge.net; Fri, 11 Nov 2005 07:33:17 -0800
To: Edward Hibbert <Edward.Hibbert@dataconnection.com>
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A55735BC@EDINMAIL1.ad.datcon.co.uk>
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

Edward Hibbert wrote:

>Thanks for your replies.  We're getting round this by ensuring that we
>don't rename to the same name - we can put something machine-specific in
>the destination filename fairly easily.
>
>However I should probably have said that our test app suggests this
>doesn't occur with Solaris NFS clients, which might influence people's
>opinion on whether it should be fixed.
>

I'd be surprised if this couldn't happen with Solaris clients.  They do
the same lookups and have many of the same decision making statements.
It is implemented differently, completely down in the NFS file system,
but it works about the same.

       ps


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
