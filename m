From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: (no subject)
Date: 22 Mar 2002 15:45:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslmckr78l.fsf@charged.uio.no>
References: <F109h6wT8DDQA6y4wlD00002bbc@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oQIn-0001zA-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 06:45:57 -0800
To: "Ozy Ali" <ozzeee@hotmail.com>
In-Reply-To: <F109h6wT8DDQA6y4wlD00002bbc@hotmail.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Ozy Ali <ozzeee@hotmail.com> writes:

     > hi,
     >    ive got a system running on redhat 6.2.  i am attempting to
     >    get another 2 pcs connected up top it as a network.  i am
     >    currently trying to install via nfs as i only have 1 cd in
     >    the main pc.  i have trawled through many HOWTO's and tried
     >    their ideas. (ie. change the file etc\exports) my problem is
     >    no matter wot i try i always get the same message wen i boot
     >    up the netboot.img floppy in the 2nd pc. the error reads " i
     >    could not mount that directory from the server, mount: RPC:
     >    port mapper failure - RPC:timed out.


     > im going out of my minds with this as ive been at it for about
     > 2 weeks.  any help would be greatly appreciated.


The error message is fairly explicit: the portmapper program
(a.k.a. "/sbin/portmap") on your server appears not to be accessible
to this client.

Is portmap not running on the server, or is there anything in
/etc/hosts.deny or in /etc/sysconfig/ipchains for instance that might
be blocking access to that client?

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
