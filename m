From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] NFSv3 READDIRPLUS fails SpecSFS validation test
Date: Wed, 19 Nov 2003 09:27:43 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16314.40159.297267.713829@notabene.cse.unsw.edu.au>
References: <1069121605.1244.94.camel@w-bwa1.beaverton.ibm.com>
	<16313.34113.687049.258087@notabene.cse.unsw.edu.au>
	<1069176640.4169.8.camel@w-bwa3.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    jrsantos@austin.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMEKl-0002J6-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Nov 2003 14:28:31 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AMEKj-0003bc-I4
	for nfs@lists.sourceforge.net; Tue, 18 Nov 2003 14:28:31 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <bwa@us.ibm.com>) (for <nfs@lists.sourceforge.net>)
	(for <jrsantos@austin.ibm.com>) By note With Smtp ;
	Wed, 19 Nov 2003 09:27:47 +1100
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
> On Mon, 2003-11-17 at 18:34, Neil Brown wrote:
> > 2 problems:
> > 
> >  1/ you have a called to "kmalloc" but don't check the return status!
> >   I would prefer not to use kmalloc to get a temporary buffer, but
> >   rather to grab the next page, create the entry in there, and then
> >   copy bits back.
> 
> By "next page", do you mean the next page in rqstp->rq_{res|arg}pages,
> i.e. do an svc_take_page(), create the entry, copy back, put back the
> temporary page?  Is there ever a chance that there might not be a page
> available from this pool?

Yes, that is exactly what I mean.
Ofcourse, normally you will not put back the temporary page, but
rather the tail of the directory entry encoding will be copied to the
head of that temporary page and it will become the current page (though
you will need to allow for the possibility of having to put it back if
something goe4es wrong in encoding the info).

Providing you limit the size of the response that you are willing to
return to NFSSVC_MAXBLKSIZE, there should always be an available page.

> 
> Yes, thanks, will make the necessary changes after I hear back on the
> question above, and re-submit the patch.

Thanks,
NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
