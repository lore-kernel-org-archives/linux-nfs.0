From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20-NFS-ALL slower than 2.4.20-vanilla on TCP
Date: 04 Dec 2002 11:29:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3cpe13id.fsf@charged.uio.no>
References: <Pine.LNX.4.40.0212032324560.3012-200000@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JWmQ-0007GG-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 02:29:22 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <Pine.LNX.4.40.0212032324560.3012-200000@bolt.sonic.net>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > I'm not sure where the bug is, in which patch, so I'm posting

I doubt this is a bug. It's probably a consequence of the ACCESS
patch. Could you try backing that particular patch out of the NFS_ALL
set?

Cheers,
 Trond


-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
