From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] NFSv3 READDIRPLUS fails SpecSFS validation test
Date: Tue, 18 Nov 2003 13:34:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16313.34113.687049.258087@notabene.cse.unsw.edu.au>
References: <1069121605.1244.94.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    jrsantos@austin.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ALvhc-0003Qn-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Nov 2003 18:34:52 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1ALvhb-0000bG-Of
	for nfs@lists.sourceforge.net; Mon, 17 Nov 2003 18:34:51 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <bwa@us.ibm.com>) (for <nfs@lists.sourceforge.net>)
	(for <jrsantos@austin.ibm.com>) By note With Smtp ;
	Tue, 18 Nov 2003 13:34:42 +1100
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: message from Bruce Allan on  November 17
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

On  November 17, bwa@us.ibm.com wrote:
> Hi Neil, 
> 
> We discussed this same issue a while back(*) but didn't come to a
> resolution.  Yet another group within IBM has asked for this to be
> looked into, and here is what I came up with-

Thanks.  It looks mostly good.

2 problems:

 1/ you have a called to "kmalloc" but don't check the return status!
  I would prefer not to use kmalloc to get a temporary buffer, but
  rather to grab the next page, create the entry in there, and then
  copy bits back.

 2/ I Don't think you have the error path right.
  i.e., when you have:


> +			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
> +				/* reset cd->offset and free tmp buffer */
> +				cd->offset = oldoffset;
> +				kfree(tmp);
> +				goto noexec;
> +			}

  I think it should be:

> +			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
> +				/* reset cd->offset and free tmp buffer */
> +				cd->offset = oldoffset;
> +				*p1++ = 0; *p1++ = 0;
> +			} else

as the entry, even reduced in size by the errors, may have to be split
over two pages.

NeilBrown


-------------------------------------------------------
This SF. Net email is sponsored by: GoToMyPC
GoToMyPC is the fast, easy and secure way to access your computer from
any Web browser or wireless device. Click here to Try it Free!
https://www.gotomypc.com/tr/OSDN/AW/Q4_2003/t/g22lp?Target=mm/g22lp.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
