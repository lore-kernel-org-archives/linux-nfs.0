From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: round robin dns, multihomed host, nfs mounting issues
Date: Mon, 21 Jul 2003 09:32:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16155.9859.470336.782179@gargle.gargle.HOWL>
References: <292E6FA1FCA21C45B614DAC7FBED6D4B874E66@hacssex002.ihess.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp3.unsw.edu.au ([149.171.96.70])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eNfw-0000kj-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 16:33:09 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <jdavis@hess.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Mon, 21 Jul 2003 09:33:01 +1000
To: "Davis, Jeff (Houston)" <jdavis@hess.com>
In-Reply-To: message from Davis, Jeff (Houston) on Saturday July 19
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

On Saturday July 19, jdavis@hess.com wrote:
> 
> Given Neil's comments about possible glibc bug and nfs 1.05, and my sense that it is working, is it reasonable for me to think its working?
> 
> I.e should it work?

Maybe.

It is entirely possible that I mis-diagnosed your problem.  If your
NFS server is the only route between the two subnets, I probably did.  

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
