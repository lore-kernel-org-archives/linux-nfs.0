From: "Davis, Jeff (Houston)" <jdavis@hess.com>
Subject: Re: round robin dns, multihomed host, nfs mounting issues
Date: Sun, 20 Jul 2003 18:41:16 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <292E6FA1FCA21C45B614DAC7FBED6D4B874E68@hacssex002.ihess.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [207.51.255.133] (helo=outside.ep.hess.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eNnu-00078f-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 16:41:22 -0700
To: <neilb@cse.unsw.edu.au>
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

Nfs server does not provide routing

It default routes through interface 1. Request was getting to server but =
not back to client

the system seems to be working as I hoped once I upgraded rh80 to nfs =
utils 1.05

Thanks for the help

--------------------------
Jeff Davis
Amerada Hess
Global IT Infrastructure
Technical Computing
Houston, Texas
jdavis@hess.com
713-609-5436 (work)
281-467-9448 (cell)

Sent by BlackBerry Wireless Email

-----Original Message-----
From: Neil Brown <neilb@cse.unsw.edu.au>
To: Davis, Jeff (Houston) <jdavis@hess.com>
CC: nfs@lists.sourceforge.net <nfs@lists.sourceforge.net>
Sent: Sun Jul 20 18:32:19 2003
Subject: Re: [NFS] round robin dns, multihomed host, nfs mounting issues

On Saturday July 19, jdavis@hess.com wrote:
>=20
> Given Neil's comments about possible glibc bug and nfs 1.05, and my =
sense that it is working, is it reasonable for me to think its working?
>=20
> I.e should it work?

Maybe.

It is entirely possible that I mis-diagnosed your problem.  If your
NFS server is the only route between the two subnets, I probably did. =20

However I cannot think of any recent change in nfs-utils that would
affect anything like your problem, but then my memory isn't perfect.

I suggest you test your configuration and if it works, be happy.

When I had the problem I mentioned, I used rpcinfo for testing:

  rpcinfo -u $HOSTNAME mountd 3

If run this on a representative sample of clients, using a
representative sample of server IP address, and it always works, then
I guess your problem has gone away

NeilBrown



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
