From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] NFSv3 READDIRPLUS fails SpecSFS validation test - 2nd
 ed.
Date: Thu, 20 Nov 2003 10:58:10 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16316.914.451342.638426@notabene.cse.unsw.edu.au>
References: <1069121605.1244.94.camel@w-bwa1.beaverton.ibm.com>
	<16313.34113.687049.258087@notabene.cse.unsw.edu.au>
	<1069204822.4249.11.camel@w-bwa3.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    jrsantos@austin.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMcEE-0003gp-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 15:59:22 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AMcDZ-0005S0-UV
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 15:58:42 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <bwa@us.ibm.com>) (for <nfs@lists.sourceforge.net>)
	(for <jrsantos@austin.ibm.com>) By note With Smtp ;
	Thu, 20 Nov 2003 10:58:10 +1100
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: message from Bruce Allan on  November 18
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

On  November 18, bwa@us.ibm.com wrote:
> Hi Neil,
> 
> Below is the updated patch with your recommended changes.  How does it
> look?

Looks much better.
 A little nit:  You check against NFSSVC_MAXBLKSIZE twice, once in
 nfs3xdr and once in nfs3proc.  It would be nice if nfs3xdr did the
 check and imposed it so nfs3proc could never see a too-large number.

 I was going to just fix that myself, but then discovered all the long
 lines are wrapped :-(  Could you send the patch again in some way
 that there isn't any line wrap?

Thanks
NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
