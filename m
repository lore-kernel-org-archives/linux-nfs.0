From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance problem
Date: Tue, 14 May 2002 08:41:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205140841.58623.trond.myklebust@fys.uio.no>
References: <1021302616.27660.20.camel@nb> <shs3cwwqdpv.fsf@charged.uio.no> <1021304064.27739.29.camel@nb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177W0i-0005ar-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 23:42:12 -0700
To: Nicolas Brainez <nb@many.be>
In-Reply-To: <1021304064.27739.29.camel@nb>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

M=E5ndag 13. mai 2002 17:34 skreiv Nicolas Brainez:


> Nope, I've not another network card, and i've absolutely no problem wit=
h
> others protocols like appletalk and ftp, I can't believe it's an
> hardware problem in these conditions.

That is completely irrelevant. You are comparing apples and pears: TCP ca=
n be=20
made to run reliably over pigeons. NFS uses UDP, and usually presses the=20
cards and drivers to the limit.

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
