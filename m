From: James Pearson <james-p@moving-picture.com>
Subject: Re: Permission denied
Date: Wed, 07 May 2003 17:21:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB93285.F40CC32A@moving-picture.com>
References: <Pine.LNX.4.55.0305071639490.2587@xpc5.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DRgg-0003Xv-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 09:22:34 -0700
To: Jeremy Sanders <jss@ast.cam.ac.uk>
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

What version of nfs-utils are you running on the server?

I had a problem if the server crashed before a client mount could be
recorded to /var/lib/nfs/rmtab, the client got permission denied on the
mount point after the server rebooted - see:

http://marc.theaimsgroup.com/?l=linux-nfs&m=101828003630443&w=2

This is fixed in the more recent versions of nfs-utils.

Also, if you manually attempt to umount an NFS file system (automounted
or not), but the umount fails because the file system is busy - this
will cause a problem as rpc.mountd on the server has already removed the
client from /var/lib/nfs/rmtab - which means if the server reboots, the
server has no record of the client mount, so you get permission denied
on client when it accesses the mount point ... see:

http://marc.theaimsgroup.com/?l=linux-nfs&m=104558814532107&w=2

I had this problem - my work round is not to manually umount automounted
file systems ... (or, if I have to, use a hacked version of umount that
doesn't contact rpc.mountd on the server).

James Pearson

Jeremy Sanders wrote:
> 
> I've seen this problem a couple of times (I think I reported it to the
> list before but I can find the posting). Using the automounter to mount
> home directories (rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock), it
> seems that rebooting a Linux server can give a "Permission denied" on
> the client. Further attempts at accessing the mountpoint give this error.
> It can be fixed my umounting it (if nothing is using it), and reaccessing
> the mountpoint.
> 
> The server is running RedHat's 2.4.18-27.7.x kernel, and the client is
> using 2.4.18-17.7.x (unfortunately).
> 
> dmesg on the client shows:
> 
> nfs: server server.ast.cam.ac.uk not responding, still trying
> nfs: task 57889 can't get a request slot
> nfs: server server.ast.cam.ac.uk OK
> nfs: server server.ast.cam.ac.uk OK
> 
> sendmail gave errors such as:
> 
> May  7 16:07:39 xserv1 sendmail[22255]: h47EwYl22254: forward
> /home/gmorris: transient error: Timeout on file open
> May  7 16:07:39 xserv1 sendmail[22195]: h47Eljl22194: forward
> /home/gmorris: transient error: Timeout on file open
> May  7 16:07:39 xserv1 sendmail[22255]: h47EwYl22254: forward
> /home/gmorris/.forward: Permission denied
> May  7 16:07:39 xserv1 sendmail[22195]: h47Eljl22194: forward
> /home/gmorris/.forward: Permission denied
> 
> Any ideas? I suppose it's hard to diagnose this without a network traffic
> analysis, and we're not using the standard kernel either. I suppose it
> could be an automounter bug.
> 
> Jeremy
> 
> --
> Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
> X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
> Public Key Server PGP Key ID: E1AAE053
> 
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux enterprise solutions
> www.enterpriselinuxforum.com
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
