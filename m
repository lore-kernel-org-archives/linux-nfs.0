From: "Chakri n" <chakriin5@gmail.com>
Subject: Locale support in NFS client side
Date: Wed, 6 Jun 2007 00:15:07 -0700
Message-ID: <92cbf19b0706060015i77a636fas8c9c377c66f4878d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, Trond.Myklebust@netapp.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvpjW-0003EO-H8
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 00:15:06 -0700
Received: from nz-out-0506.google.com ([64.233.162.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HvpjY-0007VE-GD
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 00:15:09 -0700
Received: by nz-out-0506.google.com with SMTP id 18so116774nzp
	for <nfs@lists.sourceforge.net>; Wed, 06 Jun 2007 00:15:07 -0700 (PDT)
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

Hi,

I am trying to access file systems using different locales from a UTF8
NFS client.
I see garbage.

Localization as such is not supported/covered in NFSV2/V3.

I am planning to write a layer on top of existing V2/V3 client and
convert server side file or directory names to UTF8 format inside
kernel, so that user level components using UTF8 always see file names
as expected by them.

Is this option explored earlier? If it is, can anyone provides me some
hooks where is the better place to start with?

Thanks in advance.

Regards
--Chakri

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
