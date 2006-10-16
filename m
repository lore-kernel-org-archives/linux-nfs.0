From: Neil Brown <neilb@suse.de>
Subject: Re: NLM lock reclaim failure
Date: Tue, 17 Oct 2006 09:17:15 +1000
Message-ID: <17716.4859.517612.851925@cse.unsw.edu.au>
References: <17711.15223.857652.522180@cse.unsw.edu.au>
	<OF639A94E6.FAC8DF55-ON88257206.006370CC-88257206.0064D091@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbi1-0008MN-S5
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:17:25 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbi1-0004CP-Bu
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:17:26 -0700
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: message from Marc Eshel on Friday October 13
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday October 13, eshel@almaden.ibm.com wrote:
> > 
> > The other is that blurring of nfsd and nlm error codes.
> 
> Your patch is much cleaner with exception of using hard coded return codes 
> in nlm_fopen().
>  

Yes.. fair comment.  I'll change nlm_fopen to return nlm error codes.
That makes it much nicer.

> > 
> > The following patch addresses these issues and is essentially a
> > rewrite of you patch.
> > 
> > Would you be able to review/test it?
> > 
> 
> Yes, I tested it and it fixes the problem. hope to see it in the kernel 
> soon.
> Thanks, Marc 

Thanks.  I'll send it to Andrew  shortly.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
