From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: round robin dns, multihomed host, nfs mounting issues
Date: Sat, 19 Jul 2003 20:34:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16153.7853.242076.368335@gargle.gargle.HOWL>
References: <1058549484.2552.126.camel@oac195.ep.hess.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp3.unsw.edu.au ([149.171.96.70])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dp3P-00017m-00
	for <nfs@lists.sourceforge.net>; Sat, 19 Jul 2003 03:35:03 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <jdavis@hess.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Sat, 19 Jul 2003 20:34:55 +1000
To: Jeff Davis <jdavis@hess.com>
In-Reply-To: message from Jeff Davis on  July 18
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

On  July 18, jdavis@hess.com wrote:
> I'm testing out a NFS server which has two interfaces on two different
> subnets. I'm using a single hostname and round robin dns. Clients are
> both RedHat Linux systems.
> 
> I can access the primary interface on server via NFS from any system on
> my network. I can only access the second interface from hosts on the
> same subnet. Unfortunately, round robin dns on systems that are not
> local to subnets on either of the server's nics will randomly get one of
> the two nics to access nfs fs through. 
> 
> int 1 - 192.168.19.224
> int 2 - 172.25.2.106
> 
> # can mount through int 1 from any host\
> # can mount thoughh int 2 from same ip subnet as int 2
> # cannot mount throught int 2 from remote ip subnets
> # on local subnets, mounts work as desired through correct, optimal
> interface on nfs server
> 
> # on remote subnets, round robin directs ~50% of mount requests
> to server through int 2 which fail
> 
> why doesn't this work?

Looks like you've hit a glibc bug that was only fixed relatively
recently (27th Feb 2003.  glibc version 2.3.2 or 2.3.3 I think).

When mountd is sending it's reply, it uses sendmsg and insists that the
reply goes out the same interface that the request came in on.  If
that interface doesn't have a route to the client, you lose.

I worked around it by putting a default route on all my interfaces.

> upgrading to nfs-utils 1.05 seems to have helped

I doubt that it really did, but if it works now, great.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
