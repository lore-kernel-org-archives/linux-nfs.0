From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 09:32:30 -0700
Message-ID: <1129912351.9014.29.camel@lade.trondhjem.org>
References: <cmu-lmtpd-31394-1129908191-0@mail-imap5.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESzpK-0007P7-Nd
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:33:06 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESzpH-0005NO-WC
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:33:06 -0700
To: petter.knutsen@cgi.no
In-Reply-To: <cmu-lmtpd-31394-1129908191-0@mail-imap5.uio.no>
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

fr den 21.10.2005 klokka 17:22 (+0200) skreiv petter.knutsen@cgi.no:
> > Note that this is not entirely accurate any more. Recent kernels will
> > emulate flock() over NFS by using fcntl() locks.
> 
> I've gotten fcntl() to work, but it doesn't seem that flock() works between
> clients. Do you know which kernel version implemented the emulation? Are we
> talking about the latest 2.6.14 rc, or should a 2.6.x be sufficient? Also,
> should this emulation be enough to make flock() work between clients?

I think I went into 2.6.12, but a quick hunt through the ChangeLog file
should tell you.

The emulation should make flock() work between clients by converting
flock() calls into fcntl() calls on the wire, but this means that you
have to be very wary of using flock on the server: Linux servers (unlike
most others) will not notice conflicts between an fcntl() lock (which I
remind you is what comes in from the clients) and a flock() lock.

The best option is therefore still to convert your application to use
fcntl() locks if possible.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
