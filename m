From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 901086: NFSv2 SETATTR current server time support
Date: Tue, 21 Oct 2003 16:40:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16276.54510.792744.40216@notabene.cse.unsw.edu.au>
References: <3F93B35F.EAFC7028@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABrWR-0008MQ-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Oct 2003 01:05:43 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ABqa3-0004K7-Uj
	for nfs@lists.sourceforge.net; Tue, 21 Oct 2003 00:05:24 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Tue, 21 Oct 2003 16:40:47 +1000
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Monday October 20
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

On Monday October 20, gnb@melbourne.sgi.com wrote:
> G'day,
> 
> SGI bug 901086.
...
> 
> The NFSv2 RFC defines no such encoding for the sattr structure.  However
> Solaris and Irix machine obey a convention where passing the invalid value
> mtime.useconds=1000000 means "set both mtime and atime to the current
> server time".  The convention is documented in the book "NFS Illustrated"
> by Brent Callaghan.  The patch below implements this convention for the
> Linux client and server (hence multiple To:s).
> 

Hmmm... how delightful :-(

But, it seems not unreasonable.  I will forward nfsd patches to Linus and
Marcelo.

Thanks.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
