From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: 'random' diskless clients hangs
Date: Wed, 3 Sep 2003 21:03:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309032103.28611.bernd-schubert@web.de>
References: <NEBBIHNAFKJAFOHBHGCOAEHMEFAA.nfsmailinglist@heessels.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19udin-00045v-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 12:55:17 -0700
Received: from mailgate3.cinetic.de ([217.72.192.164])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19udim-0003v1-OR
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 12:55:16 -0700
Received: from smtp.web.de (fmsmtp02.dlan.cinetic.de [172.20.1.79])
	by mailgate3.cinetic.de (8.11.6p2/8.11.2/SuSE Linux 8.11.0-0.4) with ESMTP id h83J4Sq30621
	for <nfs@lists.sourceforge.net>; Wed, 3 Sep 2003 21:04:28 +0200
To: <nfsmailinglist@heessels.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <NEBBIHNAFKJAFOHBHGCOAEHMEFAA.nfsmailinglist@heessels.com>
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
Is there anything in the logs? Which kernel-versions are you using? If you are 
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
