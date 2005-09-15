From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS problem - close to open cache consistency broken ?
Date: Thu, 15 Sep 2005 10:19:24 -0400
Message-ID: <432982EC.4070604@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E451@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Thomas Stockheim <tommi@bub-agema.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFuaO-0004Uy-LV
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 07:19:36 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFuaK-0001pi-8H
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 07:19:36 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E451@exsvl02.hq.netapp.com>
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

Lever, Charles wrote:

>
>peter, do you happen to know how the solaris NFS client behaves when an
>application holds a file open like this?
>
>close-to-open is a convention, not a specification, so it's really up to
>the client developers to implement what they think is right.  i'm
>guessing that the Linux client is working as designed here.  i'm not
>convinced it's very *convenient* behavior, though.
>

The Solaris client issues an over the wire GETATTR for virtually every open
call.  The client also flushes data when the last reference to an open file
is closed.  This is on a per file descriptor basis and not a system wide
basis.  Therefore, even if the file is held open, the close-to-open 
semantics
are still maintained, albeit on a per file descriptor level.

The NFS client uses attributes from every call except WRITE responses to do
cache validation.  The file being open for reading and/or writing is not
taken into account.

    Thanx...

       ps




-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
