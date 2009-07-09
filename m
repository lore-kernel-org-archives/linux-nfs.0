From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2] read-modify-write page updating
Date: Thu, 09 Jul 2009 11:39:32 -0400
Message-ID: <1247153972.5766.15.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
	 <1243963631.4868.124.camel@heimdal.trondhjem.org>
	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>
	 <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com>
	 <1244138698.5203.59.camel@heimdal.trondhjem.org>
	 <4A428482.60403@redhat.com>  <4A55FAC8.5040309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33168 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757182AbZGIPjj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2009 11:39:39 -0400
In-Reply-To: <4A55FAC8.5040309@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-07-09 at 10:12 -0400, Peter Staubach wrote:

> Signed-off-by: Peter Staubach <staubach@redhat.com>

Please could you send such patches as inline, rather than as
attachments. It makes it harder to comment on the patch contents...

> +static int nfs_want_read_modify_write(struct file *file, struct page *page,
> +			loff_t pos, unsigned len)
> +{
> +	unsigned int pglen = nfs_page_length(page);
> +	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
> +	unsigned int end = offset + len;
> +
> +	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
> +	    !PageUptodate(page) &&		/* Uptodate? */
> +	    !PageDirty(page) &&			/* Dirty already? */
> +	    !PagePrivate(page) &&		/* i/o request already? */

I don't think you need the PageDirty() test. These days we should be
guaranteed to always have PagePrivate() set whenever PageDirty() is
(although the converse is not true). Anything else would be a bug...

> +	    pglen &&				/* valid bytes of file? */
> +	    (end < pglen || offset))		/* replace all valid bytes? */
> +		return 1;
> +	return 0;
> +}
> +

