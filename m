From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: (no subject)
Date: 27 Jan 2003 16:17:08 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0lmwrkb.fsf@charged.uio.no>
References: <OF74631263.0B676C00-ONC1256CBB.00447DC5-C1256CBB.004ECC4B@nbg.temic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18dB0k-0001n9-00
	for <nfs@lists.sourceforge.net>; Mon, 27 Jan 2003 07:17:22 -0800
To: Emanuel.Quass@temic.com
In-Reply-To: <OF74631263.0B676C00-ONC1256CBB.00447DC5-C1256CBB.004ECC4B@nbg.temic.de>
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

>>>>> " " =3D=3D Emanuel Quass <Emanuel.Quass@temic.com> writes:

     > (DF) Can anyone explain to me why the Client is looking for a
     > file "df" and what does "Unknown/1" mean?  Thanks for any help
     > or hints (If you need additional information please ask) =A0 =A0 =A0
     > =A0 Emanuel

Trivial reply: someone is running 'df' and PATH references some
directory on the NFS server perhaps? 'Unknown' means just what is
says: 'df' was not found in the directories referenced by the PATH.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
