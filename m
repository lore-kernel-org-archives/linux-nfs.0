From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: Broken umount -f
Date: Wed, 15 Jan 2003 22:37:52 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030116033752.GA30599@questra.com>
References: <5CA6F03EF05E0046AC5594562398B9160C77EC@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Z0qo-0003DY-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 19:37:54 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 8E412AB828
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 22:37:52 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9160C77EC@POEXMB3.conoco.net>
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

Heflin, Roger A. on Wed 15/01 13:59 -0600:
> Thinking about it, having non-intr won't save you in any way shape for
> form.

although I tried, I can't think of a case where this is wrong.  I'll
just remount my filesystems with `intr'.  But, I still think that with
`intr', umount -f should work.

perhaps `nointr' should be the default mount option.

btw the NFS HOWTO recommends hard,nointr


-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
