From: <nfsmailinglist@heessels.com>
Subject: RE: 'random' diskless clients hangs
Date: Fri, 5 Sep 2003 20:46:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <NEBBIHNAFKJAFOHBHGCOKEJGEFAA.nfsmailinglist@heessels.com>
References: <200309032103.28611.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vLbZ-00053U-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Sep 2003 11:46:45 -0700
Received: from smtp2.mail.be.easynet.net ([212.100.160.76])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19vLbY-00035i-It
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 11:46:44 -0700
Received: from 212-100-181-22.adsl.easynet.be ([212.100.181.22] helo=SHEPHERD)
	by smtp2.mail.be.easynet.net with smtp (Exim 4.22)
	id 19vLbW-0000Ak-H4
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 20:46:42 +0200
To: <nfs@lists.sourceforge.net>
In-Reply-To: <200309032103.28611.bernd-schubert@web.de>
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

The clients still hang every few hours. There is nothing in the logs.
When we change the rsize and wsize to 2048, the cleint no longer crash but
clients and server because extremely slow.

Please help! We are willing to pay a fee, by the way, if someone is
interested in take a good hard look at our problem.

This is our setup:

SERVER:
=======

Linux Red Hat 7.3 kernel 2.4.18-27.7.x
nfs-utils-1.0.5-1

netboot settings:
label linux
  kernel vmlinuz
  ipappend 1
  append   root=/dev/nfs
nfsroot=192.168.1.112:/clients/%s/root,v3,nolock,intr,rsize=4096,wsize=4096

exports:
/clients/blue/root
192.168.1.160/255.255.255.255(rw,no_root_squash,sync)

CLIENTS:
========

Linux Red Hat 7.3 kernel 2.4.20-18.7custom
nfs-utils-1.0.5-1

fstab:
192.168.1.112:/clients/blue/root                /           nfs
rw,nfsvers=3,hard,intr,udp,nolock   0 0


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Bernd Schubert
Sent: woensdag 3 september 2003 21:03
To: nfsmailinglist@heessels.com; nfs@lists.sourceforge.net
Subject: Re: [NFS] 'random' diskless clients hangs


On Wednesday 03 September 2003 11:33, nfsmailinglist@heessels.com wrote:
> Hello,
>
> We have a setup with a NFS V3 Fileserver and diskless clients all running
> Red Hat 7.3.
>
> All clients run fine for days at a time, but every now and then a client
> hangs. Most of the time the process that is porbably causing the hang is
> either rhn_check (from Red Hat Network) or httpsd with user psaadm (from
> Plesk 6.0.1).
>
> Since we are new to NFS we're not sure how to track down this problem. Any
> help would be VERY much appreciated!
>

Hello,

we are also using diskless clients but have never seen something like this,
though none of your hanging programs is running on your systems.
Is there anything in the logs? Which kernel-versions are you using? If you
are
using redhat kernel you should try a vanilla kernel (2.4.21 *NOT* 2.4.22).

Btw, how is your diskless setup working? Perhaps there's something wrong?

Regards,
	Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
