From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: Large export list leads to "Invalid argument" errors when
	executing 'exportfs -r'
Date: 07 Jul 2003 12:14:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1057572896.14659.16.camel@ikarus>
References: <1057405449.3361.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ZUXg-0005JM-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Jul 2003 04:52:24 -0700
To: mschmitt@inf.ethz.ch
In-Reply-To: <1057405449.3361.64.camel@localhost>
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

I just wanted to add, I get many nfsd Security messages on the console,
too:

nfsd Security: //c bad export.
nfsd Security: //c bad export.
nfsd Security: //c bad export.
nfsd Security: /// bad export.
nfsd Security: //n bad export.
nfsd Security: //s bad export.
nfsd Security: //s bad export.
nfsd Security: //n bad export.
nfsd Security: //w bad export.
nfsd Security: //w bad export.
nfsd Security: //l bad export.
nfsd Security: //n bad export.

The directory structure for the homes described in the original post
does not match reality, it's:

/export/home/<first letter of login>/<login>

I guess the error messages above refer to <first letter of login>. But
there are no exports on the /export/home/<first letter of login> at all
in /etc/exports...

Regards,
    Marc



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
