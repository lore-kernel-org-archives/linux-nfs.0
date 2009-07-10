From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2] read-modify-write page updating
Date: Fri, 10 Jul 2009 13:22:14 -0400
Message-ID: <20090710172214.GB9927@fieldses.org>
References: <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com> <1243963631.4868.124.camel@heimdal.trondhjem.org> <18982.41770.293636.786518@fisica.ufpr.br> <1244049027.5603.5.camel@heimdal.trondhjem.org> <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com> <1244138698.5203.59.camel@heimdal.trondhjem.org> <4A428482.60403@redhat.com> <4A55FAC8.5040309@redhat.com> <1247153972.5766.15.camel@heimdal.trondhjem.org> <4A5764CE.70804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41355 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbZGJRpQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2009 13:45:16 -0400
In-Reply-To: <4A5764CE.70804@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2009 at 11:57:02AM -0400, Peter Staubach wrote:
> Trond Myklebust wrote:
>> On Thu, 2009-07-09 at 10:12 -0400, Peter Staubach wrote:
>>
>>   
>>> Signed-off-by: Peter Staubach <staubach@redhat.com>
>>>     
>>
>> Please could you send such patches as inline, rather than as
>> attachments. It makes it harder to comment on the patch contents...
>>
>>   
>
> I will investigate how to do this.

See Documentation/email-clients.txt.  (It has an entry for Thunderbird,
for example.)

--b.

>
>>> +static int nfs_want_read_modify_write(struct file *file, struct page *page,
>>> +			loff_t pos, unsigned len)
>>> +{
>>> +	unsigned int pglen = nfs_page_length(page);
>>> +	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
>>> +	unsigned int end = offset + len;
>>> +
>>> +	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
>>> +	    !PageUptodate(page) &&		/* Uptodate? */
>>> +	    !PageDirty(page) &&			/* Dirty already? */
>>> +	    !PagePrivate(page) &&		/* i/o request already? */
>>>     
>>
>> I don't think you need the PageDirty() test. These days we should be
>> guaranteed to always have PagePrivate() set whenever PageDirty() is
>> (although the converse is not true). Anything else would be a bug...
>>
>>   
>
> Okie doke.  It seemed to me that this should be true, but it was
> safer to leave both tests.
>
> I will remove that PageDirty test, retest, and then send another
> version of the patch.  I will be out next week, so it will take a
> couple of weeks.
>
>    Thanx...
>
>       ps
>
>>> +	    pglen &&				/* valid bytes of file? */
>>> +	    (end < pglen || offset))		/* replace all valid bytes? */
>>> +		return 1;
>>> +	return 0;
>>> +}
>>> +
>>>     
>>
>>   
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
