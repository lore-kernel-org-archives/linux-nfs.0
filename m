From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: Corrupt Data when using NFS on Linux
Date: Mon, 28 Oct 2002 17:34:38 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBMEKGCGAA.enorwood@effrem.com>
References: <007601c27ed6$74986240$2864a8c0@alanw>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186LHN-0002Of-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 17:34:49 -0800
To: "Alan Witz" <awitz@magstarinc.com>,
   "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <007601c27ed6$74986240$2864a8c0@alanw>
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

Hi Alan,

>    rsize=8192,wsize=8192,noac,hard,sync,nfsvers=3
>
>Any thoughts would be greatly appreciated.

>From my own experiences with similar issues, I think you have two and maybe
three options:

1. Stick with your own Linux locking scheme until the kernel catches up. It
will eventually as there are a lot of darn smart people working on it-like
those on this list. :)
2. Possibly use FreeBSD? I don't know if it addresses this problem or not.
Does anyone know if FreeBSD works here?
3. Get a non-free working commercial solution like a Network Appliance
filer.

Eff Norwood





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
