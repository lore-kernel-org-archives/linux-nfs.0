From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH v2] read-modify-write page updating
Date: Fri, 10 Jul 2009 11:57:02 -0400
Message-ID: <4A5764CE.70804@redhat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.0
 0613ABC@us.ibm.com>	 <1244138698.5203.59.camel@heimdal.trondhjem.org>	 <4A428482.60403@redhat.com>  <4A55FAC8.5040309@redhat.com> <1247153972.5766.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50990 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbZGJP5L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2009 11:57:11 -0400
In-Reply-To: <1247153972.5766.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Thu, 2009-07-09 at 10:12 -0400, Peter Staubach wrote:
>
>   
>> Signed-off-by: Peter Staubach <staubach@redhat.com>
>>     
>
> Please could you send such patches as inline, rather than as
> attachments. It makes it harder to comment on the patch contents...
>
>   

I will investigate how to do this.

>> +static int nfs_want_read_modify_write(struct file *file, struct page *page,
>> +			loff_t pos, unsigned len)
>> +{
>> +	unsigned int pglen = nfs_page_length(page);
>> +	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
>> +	unsigned int end = offset + len;
>> +
>> +	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
>> +	    !PageUptodate(page) &&		/* Uptodate? */
>> +	    !PageDirty(page) &&			/* Dirty already? */
>> +	    !PagePrivate(page) &&		/* i/o request already? */
>>     
>
> I don't think you need the PageDirty() test. These days we should be
> guaranteed to always have PagePrivate() set whenever PageDirty() is
> (although the converse is not true). Anything else would be a bug...
>
>   

Okie doke.  It seemed to me that this should be true, but it was
safer to leave both tests.

I will remove that PageDirty test, retest, and then send another
version of the patch.  I will be out next week, so it will take a
couple of weeks.

    Thanx...

       ps

>> +	    pglen &&				/* valid bytes of file? */
>> +	    (end < pglen || offset))		/* replace all valid bytes? */
>> +		return 1;
>> +	return 0;
>> +}
>> +
>>     
>
>   

