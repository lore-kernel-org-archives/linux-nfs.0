From: canon@pookie.nersc.gov
Subject: Re: 2.4.20rc1 NFS V3 UDP client problems
Date: Thu, 14 Nov 2002 12:33:16 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200211142033.gAEKXGHe010083@pookie.nersc.gov>
References: <trond.myklebust@fys.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Whiting <ewhiting@amis.com>,
   "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pookie.nersc.gov ([128.55.16.113])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CQVu-0001Em-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 12:22:58 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: Message from Trond Myklebust <trond.myklebust@fys.uio.no>
   of "14 Nov 2002 20:47:46 +0100." <shsptt83pct.fsf@helicity.uio.no>
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



We had to set our MTUs to 8960 for things to work.
We've never followed through to see what the issue
was though.

We are using SysKonnect cards and 2.4.18 kernel.  Note, 
we haven't recently verified that the problem still
exists.

--Shane



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
