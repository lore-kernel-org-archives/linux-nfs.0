From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Can't mount nfs rw
Date: Thu, 5 Sep 2002 12:34:08 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15734.49824.606700.166745@notabene.cse.unsw.edu.au>
References: <003e01c2543a$0cb85ac0$9300a8c0@gridlock>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mmTK-0008Jx-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 19:34:18 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <nlafferty@pennswoods.net>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 5 Sep 2002 12:34:09 +1000
To: "Nicholas Lafferty" <nlafferty@pennswoods.net>
In-Reply-To: message from Nicholas Lafferty on Wednesday September 4
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

On Wednesday September 4, nlafferty@pennswoods.net wrote:
> I'm having problems getting my diskless clients to mount NFS directories in
> Read-Write mode. I'm using bpbatch and tftp to transfer the kernel and a
> ramdisk for the root file system. I pass an initscript to the kernel that
> mounts the root file system of the server as read-only (mounts on /ro),
> /home/guest/share mounts as ro2 (read-only), and /home/guest/01 mounts as
> /rw (read-write). Then init is invoked. The problem is that all of the
> mounts are read-only.
> 
> #Here is what my initscript does for the mounts.
> mount-t nfs -o nolock,ro,vers=2 $SERVER:/      /ro
> mount-t nfs -o nolock,ro,vers=2 $SERVER:/home/guest/share      /ro2
> mount-t nfs -o nolock,rw,vers=2 $SERVER:/home/guest/$ID      /rw
> 
> /sbin/init '#'
> 
> # Here is my /etc/exports
> /
> 192.168.0.0/255.255.255.0(ro,no_root_squash)
> /home/guest/share       192.168.0.0(ro,no_root,squash)
> /home/guest/01            192.168.0.0(rw,no_root_squash)
> /home/guest/02            192.168.0.0(rw,no_root_squash)
> /home/guest/03            192.168.0.0(rw,no_root_squash)
> 
> Any suggestions on some other things to try?
> 


perl -i -p -e 's,192.168.0.0\(,192.168.0.0/255.255.255.0\(,' /etc/exports

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
