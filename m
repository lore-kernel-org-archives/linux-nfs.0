From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [PATCH] NFSv3 READDIRPLUS fails SpecSFS validation test
Date: 18 Nov 2003 09:30:40 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069176640.4169.8.camel@w-bwa3.beaverton.ibm.com>
References: <1069121605.1244.94.camel@w-bwa1.beaverton.ibm.com>
	 <16313.34113.687049.258087@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, jrsantos@austin.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AM9gi-0007bR-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Nov 2003 09:30:52 -0800
Received: from e32.co.us.ibm.com ([32.97.110.130])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AM9gi-0005sm-0o
	for nfs@lists.sourceforge.net; Tue, 18 Nov 2003 09:30:52 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16313.34113.687049.258087@notabene.cse.unsw.edu.au>
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

On Mon, 2003-11-17 at 18:34, Neil Brown wrote:
> On  November 17, bwa@us.ibm.com wrote:
> > Hi Neil, 
> > 
> > We discussed this same issue a while back(*) but didn't come to a
> > resolution.  Yet another group within IBM has asked for this to be
> > looked into, and here is what I came up with-
> 
> Thanks.  It looks mostly good.
> 
> 2 problems:
> 
>  1/ you have a called to "kmalloc" but don't check the return status!
>   I would prefer not to use kmalloc to get a temporary buffer, but
>   rather to grab the next page, create the entry in there, and then
>   copy bits back.

By "next page", do you mean the next page in rqstp->rq_{res|arg}pages,
i.e. do an svc_take_page(), create the entry, copy back, put back the
temporary page?  Is there ever a chance that there might not be a page
available from this pool?

>  2/ I Don't think you have the error path right.
>   i.e., when you have:
> 
> 
> > +			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
> > +				/* reset cd->offset and free tmp buffer */
> > +				cd->offset = oldoffset;
> > +				kfree(tmp);
> > +				goto noexec;
> > +			}
> 
>   I think it should be:
> 
> > +			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
> > +				/* reset cd->offset and free tmp buffer */
> > +				cd->offset = oldoffset;
> > +				*p1++ = 0; *p1++ = 0;
> > +			} else
> 
> as the entry, even reduced in size by the errors, may have to be split
> over two pages.
> 
> NeilBrown
> 

Yes, thanks, will make the necessary changes after I hear back on the
question above, and re-submit the patch.

Thanks again,
Bruce



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
