From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Status of mount.nfs
Date: Mon, 9 Jul 2007 11:55:41 +0200
Message-ID: <20070709095511.GA17815@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: lamont@debian.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7py9-0001eC-9z
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 02:55:52 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I7pyB-00034m-B3
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 02:55:52 -0700
In-Reply-To: <18065.43199.104020.412029@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, Jul 09, 2007 at 01:17:19PM +1000, Neil Brown wrote:
> I wonder why you didn't find:
> commit b3b111b1bd5fbc678419bf1964b6093045081139
> Author: Neil Brown <neilb@suse.de>
> Date:   Tue Mar 20 14:18:41 2007 +1100
> 
>     Build mount.nfs by default, and install setuid
>     
>     Also fix a few bugs that came up in initial testing.

There's a simple explanation for that -- I checked the file ChangeLog, which
doesn't seem to have been updated since September, now that I look at it. I
guess you stopped updating it at some point...

> nfs-utils-1.1.0 builds and install mount.nfs by default, and should be
> used with the new util-linux.

Thanks for the clarification; we'll make the switch pretty shortly.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
