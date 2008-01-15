From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 15 Jan 2008 11:38:36 -0500
Message-ID: <6613E79A-7C3E-4414-8792-EDB0DF87A87D@oracle.com>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org> <20080108174958.GA25025@infradead.org> <4783E3C9.3040803@redhat.com> <20080109180214.GA31071@infradead.org> <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com> <20080114230742.GA16975@fieldses.org> <18315.61638.14133.308991@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53999 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbYAOQjs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 11:39:48 -0500
In-Reply-To: <18315.61638.14133.308991-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 14, 2008, at 6:31 PM, Neil Brown wrote:
> On Monday January 14, bfields@fieldses.org wrote:
>>>
>>> +static ssize_t failover_unlock_ip(struct file *file, char *buf,  
>>> size_t size)
>>> +{
>>> +	__be32 server_ip;
>>> +	char *fo_path;
>>> +	char *mesg;
>>> +
>>> +	/* sanity check */
>>> +	if (size <= 0)
>>> +		return -EINVAL;
>>
>> Not only is size never negative, it's actually an unsigned type  
>> here, so
>> this is a no-op.
>
> No,  It it equivalent to
>           if (size == 0)
>
> which alternative is clearer and more maintainable is debatable.

I think Wendy should fix this.  Otherwise, it can easily confuse  
someone trying to read this code.  If the equals-zero check is  
needed, leave that part.  But it's not clear what is intended by the  
less-than-zero check on an unsigned.

And, if we ever enable thorough compiler warnings, the less-than-zero  
check will cause the compiler to throw needless warnings, adding to  
noise.

>>> +
>>> +	if (buf[size-1] == '\n')
>>> +		buf[size-1] = 0;
>>
>> The other write methods in this file actually just do
>>
>> 	if (buf[size-1] != '\n')
>> 		return -EINVAL;
>
> and those which don't check for size == 0 are underflowing an array.
> That should probably be fixed.
>
>>
>> I don't know why.  But absent some reason, I'd rather these two new
>> files behaved the same as existing ones.
>>
>>> +
>>> +	fo_path = mesg = buf;
>>> +	if (qword_get(&mesg, fo_path, size) < 0)
>>> +		return -EINVAL;
>>
>> "mesg" is unneeded here, right?  You can just do:
>>
>> 	fo_path = buf;
>> 	if (qword_get(&buf, buf, size) < 0)
>>
>>> +
>>> +	server_ip = in_aton(fo_path);
>>
>> It'd be nice if we could sanity-check this.  (Is there code  
>> already in
>> the kernel someplace to do this?)
>
> In ip_map_parse we do:
>
> 	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
> 		return -EINVAL;
> 	...
> 	addr.s_addr =
> 		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
>
> I suspect that would fit in an inline function somewhere quite
> nicely. but where?

By sanity-check, I assumed Bruce meant that the value of fo_path  
ought to be verified as a valid IP address, and not some arbitrary  
string.  I think in_aton() actually returns INADDR_ANY if it can't  
parse the passed-in string, so a check for that after the in_aton()  
call might be sufficient.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



