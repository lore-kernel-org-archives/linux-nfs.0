From: Alex Thiel <stderr@web.de>
Subject: Re: nfs-utils 1.0.3 compile error w/gcc-3.2.2
Date: Fri, 28 Mar 2003 15:57:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200303281557.29049.stderr@web.de>
References: <3E844E32.4000008@lucidpixels.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailout06.sul.t-online.com ([194.25.134.19])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yvIr-0001IQ-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Mar 2003 06:57:57 -0800
To: Justin Piszcz <jpiszcz@lucidpixels.com>,
 nfs@lists.sourceforge.net
In-Reply-To: <3E844E32.4000008@lucidpixels.com>
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

On Friday 28 March 2003 14:29, Justin Piszcz wrote:
> -rw-r--r--    1 war      wheel        2.7k Mar 28 08:24 log.bz2
>
> The error is contained in the attachment.

Did you notice this in your log:

Making all in export
rm -f mount.h mount_clnt.c mount_xdr.c
../../bin/rpcgen -h -o mount.h mount.x
cannot find any C preprocessor (cpp)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Make sure cpp is in your search path.

	Alex



-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
