From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: regarding size limit of local client cache
Date: 11 Mar 2003 23:14:07 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsof4h7dqo.fsf@charged.uio.no>
References: <20030311211231.55780.qmail@web11407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ss0n-0007h4-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 14:14:17 -0800
To: Abhishek Rai <abbashake007@yahoo.com>
In-Reply-To: <20030311211231.55780.qmail@web11407.mail.yahoo.com>
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

>>>>> " " == Abhishek Rai <abbashake007@yahoo.com> writes:

     > But in any case, I have a large swap partition(500 MB). So why
     > doesn't the NFS client make use of the swap space to enlarge
     > its available page cache space rather than restricting its page
     > cache usage to 8192 -4k pages and thus paying the penalty of a
     > very high numbe of on the wire reads.(As i mentioned before,
     > there is negligible load on the client apart from the NFS)

There is no guarantee that swap will be faster than NFS. Think GigE or
faster...

In any case, this is an area that in entirely under the control of the
VM. NFS has no say whatsoever in what policy should be applied
w.r.t. caching.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
