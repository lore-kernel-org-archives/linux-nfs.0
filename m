From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Weird error with nfs server and an embedded linux system.
Date: 29 Jul 2002 15:14:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65yy4qwx.fsf@charged.uio.no>
References: <Pine.LNX.4.33.0207291531280.12454-100000@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZAMM-0006is-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 06:14:50 -0700
To: <sampo.nurmentaus@audioriders.fi>
In-Reply-To: <Pine.LNX.4.33.0207291531280.12454-100000@localhost>
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

>>>>> " " == Sampo Nurmentaus <audiopoppi-13@audioriders.fi> writes:

     > Hello folks,

     > I ported all the nfs stuff to our embedded system running
     > 2.4.14 on cris platform.  All the daemons start up nicely
     > except the statd that prints to log that:

     > Jul 29 12:58:06 noisy25 statd[124]: Version from Hell! Starting

     > But it starts up anyway.

     > When I try to mount a share it ses in syslog that mount request
     > is authenticated and my laptops ip appears in xtab but still
     > the mount fails with fallowing error message:

     > [root@kombo root]# mount -t nfs -o nolock
     > 120.100.100.25:/tmp/hd /mnt/keke/ mount: RPC: Remote system
     > error

If you are mounting using 'nolock', then you won't care if statd is
running or not. rpc.statd is only required if you need file locking
over NFS.

Your mount error is therefore likely to be due to some other
problem. I suggest you have a look at the RPC exchange between client
and server using the 'ethereal' program. That should show you what is
going wrong...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
