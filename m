From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 1/3] enhanced ESTALE error handling
Date: Fri, 18 Jan 2008 12:32:05 -0500
Message-ID: <4790E295.6010301@redhat.com>
References: <4790C761.1010603@redhat.com> <20080118161443.GB20490@parisc-linux.org> <4790D7C0.30402@redhat.com> <20080118171805.GA15158@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764538AbYARRcq@vger.kernel.org>
In-Reply-To: <20080118171805.GA15158@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jan 18, 2008 at 11:45:52AM -0500, Peter Staubach wrote:
>   
>> Matthew Wilcox wrote:
>>     
>>> On Fri, Jan 18, 2008 at 10:36:01AM -0500, Peter Staubach wrote:
>>>       
>>>>  static int path_lookup_create(int dfd, const char *name,
>>>> -			      unsigned int lookup_flags, struct nameidata *nd,
>>>> -			      int open_flags, int create_mode)
>>>> +		unsigned int lookup_flags, struct nameidata *nd,
>>>> +		int open_flags, int create_mode)
>>>>     
>>>>         
>>> Gratuitous reformatting?
>>>
>>>   
>>>       
>> Elimination of an overly long line?
>>     
>
> I usually try to gather any coding style, comment grammar, etc., fixes
> into a single patch or two at the beginning of a series.  That keeps the
> substantive patches (the hardest to understand) shorter.
>
>   

That's probably great advice.  I can easily enough undo the change
since it does not affect the functionality of the patch.  It was
made while I was doing the analysis for the patch and to make the
style better match the style used in other surrounding routines.

    Thanx...

       ps

> --b.
>
>   
>>>> @@ -1712,7 +1729,10 @@ int open_namei(int dfd, const char *path
>>>>  	int acc_mode, error;
>>>>  	struct path path;
>>>>  	struct dentry *dir;
>>>> -	int count = 0;
>>>> +	int count;
>>>> +
>>>> +top:
>>>> +	count = 0;
>>>>   	acc_mode = ACC_MODE(flag);
>>>>  @@ -1739,7 +1759,8 @@ int open_namei(int dfd, const char *path
>>>>  	/*
>>>>  	 * Create - we need to know the parent.
>>>>  	 */
>>>> -	error = path_lookup_create(dfd,pathname,LOOKUP_PARENT,nd,flag,mode);
>>>> +	error = path_lookup_create(dfd, pathname, LOOKUP_PARENT, nd,
>>>> +				flag, mode);
>>>>  	if (error)
>>>>  		return error;
>>>>  @@ -1812,10 +1833,17 @@ ok:
>>>>  	return 0;
>>>>   exit_dput:
>>>> +	if (error == -ESTALE)
>>>> +		d_drop(path.dentry);
>>>>  	dput_path(&path, nd);
>>>>  exit:
>>>>  	if (!IS_ERR(nd->intent.open.file))
>>>>  		release_open_intent(nd);
>>>> +	if (error == -ESTALE) {
>>>> +		d_drop(nd->dentry);
>>>> +		path_release(nd);
>>>> +		goto top;
>>>> +	}
>>>>     
>>>>         
>>> I wonder if a tail-call might not work better here.
>>>       
>> "Tail-call"?
>>
>>    Thanx...
>>
>>       ps
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     

