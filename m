From: "Timothy G. Wesemann" <timwese@voicenet.com>
Subject: Re: nfs: server X not responding, still trying
Date: Wed, 5 Nov 2003 13:03:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <086e01c3a3c7$2b2af200$de0167cf@voicenet.com>
References: <482A3FA0050D21419C269D13989C6113020AC622@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AHT42-0005Yy-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Nov 2003 11:11:34 -0800
Received: from mail08.voicenet.com ([207.103.0.34])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AHSwv-0001Bw-NF
	for nfs@lists.sourceforge.net; Wed, 05 Nov 2003 11:04:13 -0800
To: <nfs@lists.sourceforge.net>
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

>> the async mount option is not needed, as async is the default.
>the async export option is to be avoided.

If that is so, then why does my exportfs (from nfs-utils-1.0.6) state the
following when exporting?

=================================
   exportfs: /etc/exports [4]: No 'sync' or 'async' option specified for
export "192.168.10.0/24:/jetstor/incoming".
      Assuming default behaviour ('sync').
      NOTE: this default has changed from previous versions
=================================

--
Tim Wesemann



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
