From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Wed, 15 Jan 2003 13:24:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115182436.GO30598@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com> <20030115130759.B11894@ti19>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YsDN-0002Zk-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 10:24:37 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 74AB4AB80F
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 13:24:36 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20030115130759.B11894@ti19>
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

Bill Rugolsky Jr. on Wed 15/01 13:08 -0500:
> > do you know what the risk of data corruption is when using "intr"?
> > seems pretty low to me.
> 
> Any reason why we can't add a mount option that makes cl_intr only
> effective for SIGKILL in sunrpc/clnt.c?

and how about also only if euid == 0


-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
