From: Chip Salzenberg <chip@debian.org>
Subject: Possible breakthrough Re: Debian Bug#203918 - statd request on eth interface, not localhost?
Date: Thu, 21 Aug 2003 14:02:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030821180214.GA12129@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jordi Mallach <jordi@debian.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pu5s-0006en-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Aug 2003 11:23:32 -0700
To: nfs@lists.sourceforge.net
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

(Jordi, this is an edited msg copied to the NFS list.)

According to Jordi Mallach:
> On Thu, Aug 21, 2003 at 10:40:28AM -0400, Chip Salzenberg wrote:
> > Hm.  I don't suppose if you type
> >    host 127.0.0.1
> >    host localhost
> > it fails?  I know, long shot.  :-)  Looks like a dead end.
> 
> Heh, maybe not...
> 
> I'm assuming you're interested on the server.
> 
> host 127.0.0.1 is ok, but...
> 
> 20740:jordi@natura:~$ host localhost 
> localhost.int.oskuro.net does not exist (Authoritative answer)
> zsh: exit 69    host localhost

That *is* interesting.  It's possible that statd and even portmap will
refuse to accept requests from localhost, since your /etc/hosts.deny
says "ALL: PARANOID", and your loopback interface fails the paranoia
test.

Could you please do what it takes to make "host localhost" and "host
127.0.0.1" work on both client *and* server, and see if your problem
goes away?  Either that or add "ALL: 127.0.0.1" to /etc/hosts.allow.

Hm.  Things could be breaking even sooner than that, depending on
whether any of nfs-utils depends on the name "localhost"....

> both boxes have a
> 
> 127.0.0.1       localhost
> 
> line in /etc/hosts.

Hm again.  I wonder if the tcpwrappers paranoia check uses /etc/hosts.

(Sorry for the resend, Jordi.)
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
