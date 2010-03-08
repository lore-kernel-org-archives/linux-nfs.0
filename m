From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/7] nfsd4: edit comment for concision
Date: Mon, 8 Mar 2010 13:10:05 -0500
Message-ID: <20100308181005.GA1675@fieldses.org>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu> <1267571573-11844-2-git-send-email-bfields@citi.umich.edu> <1267571573-11844-3-git-send-email-bfields@citi.umich.edu> <4B8EA527.5060502@oracle.com> <20100306185028.GE22650@fieldses.org> <4B951864.1040903@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43155 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535Ab0CHSIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 13:08:42 -0500
In-Reply-To: <4B951864.1040903@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 08, 2010 at 10:31:48AM -0500, Chuck Lever wrote:
> On 03/06/2010 01:50 PM, J. Bruce Fields wrote:
>> On Wed, Mar 03, 2010 at 01:06:31PM -0500, Chuck Lever wrote:
>>> On 03/02/2010 06:12 PM, J. Bruce Fields wrote:
>>>> Also note units are seconds.
>>>
>>> I'd prefer the major edits in this patch be done at the same time you
>>> trim the other documenting comments for the /proc/fs/nfsd API.
>>
>> Not sure when I'll have the time to do that, but, OK: dropped for now.
>>
>> Do you think there's any loss of information or readability from the
>> shorter format?
>
> The reason I spelled it all out carefully is because this code can  
> sometimes change in subtle ways, and the whole API implementation is  
> spread out over several source files.

Understood.  I should have been more specific: in the particular example
below, do you think their was any loss?

--b.

> IMO, we need to have a reference  
> specification that describes how this API _should_ work, despite what  
> the code says.
>
> (In other words, it's one of those cases where the code documents how  
> the API _does_ work, not how it _should_ work, and the latter is pretty  
> important.  So comments are rather necessary I think).
>
> You could successfully put the block comments on a diet, but going too  
> far would reduce the value of having the comments in the first place.
>
> My main objection to this patch was that we need to have a more extended  
> discussion of how to reduce the size of the comments for all the proc  
> files implemented here.  That seemed to me was outside the scope of this  
> patch set, but still worth doing at some point.
>
>> --b.
>>
>>>
>>>> Signed-off-by: J. Bruce Fields<bfields@citi.umich.edu>
>>>> ---
>>>>    fs/nfsd/nfsctl.c |   21 ++++++---------------
>>>>    1 files changed, 6 insertions(+), 15 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>> index 8bff674..f1ee549 100644
>>>> --- a/fs/nfsd/nfsctl.c
>>>> +++ b/fs/nfsd/nfsctl.c
>>>> @@ -1228,23 +1228,14 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
>>>>    /**
>>>>     * write_leasetime - Set or report the current NFSv4 lease time
>>>>     *
>>>> - * Input:
>>>> - *			buf:		ignored
>>>> - *			size:		zero
>>>> + * If given a nonzero size, sets the NFSv4 lease time to a number of
>>>> + * seconds (interpreting buf as a C string containing an ascii
>>>> + * representation of the number).
>>>>     *
>>>> - * OR
>>>> + * Returns the resulting lease time (as an ascii representation in a
>>>> + * '\n'-terminated C string) in buf.
>>>>     *
>>>> - * Input:
>>>> - *			buf:		C string containing an unsigned
>>>> - *					integer value representing the new
>>>> - *					NFSv4 lease expiry time
>>>> - *			size:		non-zero length of C string in @buf
>>>> - * Output:
>>>> - *	On success:	passed-in buffer filled with '\n'-terminated C
>>>> - *			string containing unsigned integer value of the
>>>> - *			current lease expiry time;
>>>> - *			return code is the size in bytes of the string
>>>> - *	On error:	return code is zero or a negative errno value
>>>> + * Given a zero size, just returns the lease time in buf.
>>>>     */
>>>>    static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
>>>>    {
>>>
>>>
>>> --
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>
>
> -- 
> chuck[dot]lever[at]oracle[dot]com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
