From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Wed, 15 Jan 2003 12:23:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115172355.GJ30598@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YrSH-00007q-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 09:35:57 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 34A21AB7C4
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 12:23:56 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com>
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

Lever, Charles on Wed 15/01 09:04 -0800:
> > I'm sure it *will* work with the `intr' mount option.  But I don't
> > want my users to be able to corrupt their own data just because I
> > decided to bounce to server for whatever reason.
> 
> do you know what the risk of data corruption is when using "intr"?
> seems pretty low to me.

User saving his mail spool, sees "nfs server not responding, still
trying" and decides to try killing his MUA.  Too bad it works and now
his spool is a steaming pile of ASCII.

any number of other possible problems with intr

`soft' and `intr' are evil and should be banned.


-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
