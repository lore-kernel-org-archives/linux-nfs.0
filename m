From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: Premission denied
Date: Fri, 31 Oct 2003 12:19:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16289.47255.469257.741134@notabene.cse.unsw.edu.au>
References: <10334.62.49.205.2.1067421598.squirrel@squirrelmail.bim7.com>
	<20031029215815.GO29526@perlsupport.com>
	<16288.41100.10180.44099@notabene.cse.unsw.edu.au>
	<18043.62.49.205.2.1067515125.squirrel@squirrelmail.bim7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFNwu-00088m-00
	for <nfs@lists.sourceforge.net>; Thu, 30 Oct 2003 17:19:36 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AFNwt-0007CQ-L9
	for nfs@lists.sourceforge.net; Thu, 30 Oct 2003 17:19:35 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <gareth@bim7.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 31 Oct 2003 12:19:29 +1100
To: "Gareth" <gareth@bim7.com>
In-Reply-To: message from Gareth on Thursday October 30
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

On Thursday October 30, gareth@bim7.com wrote:
> >> > Someone at work suggested its a reverse DNS problem... but running
> >> > nslookup hostname returns my IP address, and vice versa.
> >>
> >> The log says there was a reverse DNS problem.  It says it clearly,
> >> right there in the log.  Are you suggesting that it's lying?
> >
> > Funny, but I don't see the letters "DNS" in the log at all :-)
> >
> > What does /etc/nsswitch.conf say about hosts? Does "files" come before
> > "dns"?
> 
> files is before dns...
> 
> the only entries in my /etc/hosts are...
> 
> # Do not remove the following line, or various programs
> # that require network functionality will fail.
> 127.0.0.1               localhost.localdomain localhost
> 192.168.17.4            paris.bim paris
> 
> does that look okay?

Yes it does.  Which makes it all very strange.
Looking back at the original message: if /etc/exports is

 /nfsroot        192.168.17.0/255.255.255.0(ro)
 /mnt/nfsroot    192.168.17.0/255.255.255.0(ro)
 
then hostname lookup shouldn't matter.
Also:

Oct 29 09:25:44 paris rpc.mountd: Fake hostname paris.bim for 192.168.17.4 - forward lookup doesn't match reverse
Oct 29 09:25:44 paris rpc.mountd: refused mount request from 192.168.17.4 for /nfsroot (/): no export entry
Oct 29 09:29:09 paris rpc.mountd: export request from 127.0.0.1
Oct 29 09:39:37 paris rpc.mountd: refused mount request from paris.bim for /nfsroot (/): no export entry

seems to indicate that at 09:39:37 hostname lookup did the right
thing.
But either way, "no export entry" was found.

What is in /var/lib/nfs/?tab  ??

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
