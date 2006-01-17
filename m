From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: (no subject)
Date: Tue, 17 Jan 2006 16:41:51 -0500
Message-ID: <1137534111.7855.194.camel@lade.trondhjem.org>
References: <20060117223733.oy3wy9yvc4so8c4s@roze.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eyyaq-0008OH-TF
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 13:42:20 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eyyao-0001T1-Kc
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 13:42:21 -0800
To: Jonas Lihnell <roze@roze.mine.nu>
In-Reply-To: <20060117223733.oy3wy9yvc4so8c4s@roze.mine.nu>
Sender: nfs-admin@lists.sourceforge.net
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

On Tue, 2006-01-17 at 22:37 +0100, Jonas Lihnell wrote:

> Some information about my setup and config files:
> pxelinux.cfg/default:
> "DEFAULT /bzImage
> APPEND ip=dhcp root=/dev/nfs 
> nfsroot=192.168.0.64:/mnt/storage/network-nodes/default,sync,hard,intr,rw,nolock,rsize=8192,wsize=8192,nfsvers=3,tcp"

Hmm... "sync" and "rw" are not listed in the nfsroot options (though I
agree that they probably should be).

What happens if you take those two out of the list?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
