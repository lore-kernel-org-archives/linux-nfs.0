From: Olaf Kirch <okir@suse.de>
Subject: Re: RFC: mount.nfs
Date: Sat, 28 Aug 2004 20:21:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040828182120.GA11199@suse.de>
References: <20040827141529.GF23324@suse.de> <4130BF21.9000701@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C17pN-0005vb-RN
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 11:21:25 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C17pL-0003TE-VV
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 11:21:25 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4130BF21.9000701@RedHat.com>
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

On Sat, Aug 28, 2004 at 01:21:37PM -0400, Steve Dickson wrote:
> >There's also no NFSv4 support yet, but if anyone would like to send
> >me patches I will gladly incorporate them. I'm also open to design
> >improvements that may make life for NFSv4 folks easier.
> > 
> >
> Does it make senses to add NFS4 to this command or create a stand-alone
> mount.nfs4 command as well? nfs4 is a separate filesystem type....

>From a convenience point of view, I think it does make sense to integrate
it _somehow_, because users simply want to type "mount foo:/bar /baz"
and have the mount command choose the best NFS version, regardless of
how things are done in the kernel. Users will hate us if we make them
read the fine print at the bottom of the nfs(5) manual page :)

Whether it ends up calling mount.nfs4 when it finds the server supports
NFSv4, or whether that logic is built into mount.nfs itself is probably
a matter of what works better for NFSv4 developers. As I said, I'm happy
to accept patches...

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
