From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS server not responding
Date: 27 Nov 2003 11:30:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsfzg93hag.fsf@charged.uio.no>
References: <1069934421.4677.77.camel@wibbit.firebox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APP2b-000264-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 08:30:53 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1APP2b-0002KC-9p
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 08:30:53 -0800
To: Douglas Furlong <douglas.furlong@firebox.com>
In-Reply-To: <1069934421.4677.77.camel@wibbit.firebox.com>
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

>>>>> " " == Douglas Furlong <douglas.furlong@firebox.com> writes:

     > Good day all.  I am running in to excessive amounts of NFS
     > errors as below.

     > kernel: nfs: server neon not responding, still trying kernel:
     > nfs: server neon OK

Two suggestions:

 1) Bump the number of threads on the server. 32 is probably a bit
    low.

 2) The value retrans=3 used as the default by the Linux 'mount'
    program is rather low compared to that used on other OSes. I
    suggest you bump it to at least 5 on all your clients.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
