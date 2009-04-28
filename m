From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [patch 03/29] knfsd: add userspace controls for stats tables
Date: Tue, 28 Apr 2009 12:03:49 -0400
Message-ID: <223A8BE7-4083-4222-83B8-6BB6C4107016@oracle.com>
References: <20090331202800.739621000@sgi.com> <20090331202938.939647000@sgi.com> <20090425215745.GA5088@fieldses.org> <20090425220329.GB5088@fieldses.org> <A11EACD6-B05E-4A1A-A38C-F65B2DFB77B3@oracle.com> <20090427232225.GB5108@fieldses.org> <4993A7C8-342E-47BE-997A-AF18E5DF41BE@oracle.com> <20090428155736.GH17891@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>, Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:21749 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762904AbZD1QEF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 12:04:05 -0400
In-Reply-To: <20090428155736.GH17891@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 28, 2009, at 11:57 AM, J. Bruce Fields wrote:

> On Tue, Apr 28, 2009 at 11:37:09AM -0400, Chuck Lever wrote:
>>
>> On Apr 27, 2009, at 7:22 PM, J. Bruce Fields wrote:
>>
>>> On Mon, Apr 27, 2009 at 12:06:18PM -0400, Chuck Lever wrote:
>>>> On Apr 25, 2009, at 6:03 PM, J. Bruce Fields wrote:
>>>>> Pfft, did it again.
>>>>>
>>>>> --b.
>>>>>
>>>>> On Sat, Apr 25, 2009 at 05:57:45PM -0400, bfields wrote:
>>>>>> On Wed, Apr 01, 2009 at 07:28:03AM +1100, Greg Banks wrote:
>>>>>>> Add two control files to /proc/fs/nfsd:
>>>>>>>
>>>>>>> * "stats_enabled" can be used to disable or enable the gathering
>>>>>>> of per-client and per-export statistics in the server.
>>>>>>>
>>>>>>> * "stats_prune_period" can be used to set the period at
>>>>>>> which the pruning timer runs, in seconds.  Unused stats
>>>>>>> entries will survive at most twice that time.
>>>>>>>
>>>>>>> Signed-off-by: Greg Banks <gnb@sgi.com>
>>>>>>> ---
>>>>>>>
>>>>>>> fs/nfsd/nfsctl.c |   99
>>>>>>> ++++++++++++++++++++++++++++++++++++++++++++
>>>>>>> 1 file changed, 99 insertions(+)
>>>>>>>
>>>>>>> Index: bfields/fs/nfsd/nfsctl.c
>>>>>>> =
>>>>>>> =
>>>>>>> =
>>>>>>> ================================================================
>>>>>>> --- bfields.orig/fs/nfsd/nfsctl.c
>>>>>>> +++ bfields/fs/nfsd/nfsctl.c
>>>>>>> @@ -64,6 +64,8 @@ enum {
>>>>>>> 	NFSD_Versions,
>>>>>>> 	NFSD_Ports,
>>>>>>> 	NFSD_MaxBlkSize,
>>>>>>> +	NFSD_Stats_Enabled,
>>>>>>> +	NFSD_Stats_Prune_Period,
>>>>>>> 	/*
>>>>>>> 	 * The below MUST come last.  Otherwise we leave a hole in
>>>>>>> nfsd_files[]
>>>>>>> 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
>>>>>>> @@ -92,6 +94,8 @@ static ssize_t write_pool_threads(struct
>>>>>>> static ssize_t write_versions(struct file *file, char *buf,  
>>>>>>> size_t
>>>>>>> size);
>>>>>>> static ssize_t write_ports(struct file *file, char *buf, size_t
>>>>>>> size);
>>>>>>> static ssize_t write_maxblksize(struct file *file, char *buf,
>>>>>>> size_t size);
>>>>>>> +static ssize_t write_stats_enabled(struct file *file, char  
>>>>>>> *buf,
>>>>>>> size_t size);
>>>>>>> +static ssize_t write_stats_prune_period(struct file *file, char
>>>>>>> *buf, size_t size);
>>>>>>> #ifdef CONFIG_NFSD_V4
>>>>>>> static ssize_t write_leasetime(struct file *file, char *buf,
>>>>>>> size_t size);
>>>>>>> static ssize_t write_recoverydir(struct file *file, char *buf,
>>>>>>> size_t size);
>>>>>>> @@ -113,6 +117,8 @@ static ssize_t (*write_op[])(struct file
>>>>>>> 	[NFSD_Versions] = write_versions,
>>>>>>> 	[NFSD_Ports] = write_ports,
>>>>>>> 	[NFSD_MaxBlkSize] = write_maxblksize,
>>>>>>> +	[NFSD_Stats_Enabled] = write_stats_enabled,
>>>>>>> +	[NFSD_Stats_Prune_Period] = write_stats_prune_period,
>>>>>>> #ifdef CONFIG_NFSD_V4
>>>>>>> 	[NFSD_Leasetime] = write_leasetime,
>>>>>>> 	[NFSD_RecoveryDir] = write_recoverydir,
>>>>>>> @@ -1121,6 +1127,97 @@ static ssize_t write_maxblksize(struct f
>>>>>>> 	return sprintf(buf, "%d\n", nfsd_max_blksize);
>>>>>>> }
>>>>>>>
>>>>>>> +extern int nfsd_stats_enabled;
>>>>>>> +
>>>>>>> +/**
>>>>>>> + * write_stats_enabled - Set or report whether per-client/
>>>>>>> + *			 per-export stats are enabled.
>>>>>>> + *
>>>>>>> + * Input:
>>>>>>> + *			buf:		ignored
>>>>>>> + *			size:		zero
>>>>>>> + *
>>>>>>> + * OR
>>>>>>> + *
>>>>>>> + * Input:
>>>>>>> + * 			buf:		C string containing an unsigned
>>>>>>> + * 					integer value representing the new value
>>>>>>> + *			size:		non-zero length of C string in @buf
>>>>>>> + * Output:
>>>>>>> + *	On success:	passed-in buffer filled with '\n'-terminated C
>>>>>>> string
>>>>>>> + *			containing numeric value of the current setting
>>>>>>> + *			return code is the size in bytes of the string
>>>>>>> + *	On error:	return code is zero or a negative errno value
>>>>>>> + */
>>>>>>> +static ssize_t write_stats_enabled(struct file *file, char  
>>>>>>> *buf,
>>>>>>> size_t size)
>>>>>>> +{
>>>>>>> +	char *mesg = buf;
>>>>>>> +	if (size > 0) {
>>>>>>> +		int enabled;
>>>>>>> +		int rv = get_int(&mesg, &enabled);
>>>>>>> +		if (rv)
>>>>>>> +			return rv;
>>>>>>> +		/* check `enabled' against allowed range */
>>>>>>> +		if (enabled < 0 || enabled > 1)
>>>>>>> +			return -EINVAL;
>>>>>>> +		/*
>>>>>>> +		 * We can change the enabled flag at any time without
>>>>>>> +		 * locking.  All it controls is whether stats are
>>>>>>> +		 * gathered for new incoming NFS calls.  Old gathered
>>>>>>> +		 * stats still sit around in the hash tables until
>>>>>>> +		 * naturally pruned.
>>>>>>> +		 */
>>>>>>> +		nfsd_stats_enabled = enabled;
>>>>>>> +	}
>>>>>>> +	return sprintf(buf, "%d\n", nfsd_stats_enabled);
>>>>>>> +}
>>>>>>> +
>>>>>>> +extern int nfsd_stats_prune_period;
>>>>>>> +
>>>>>>> +/**
>>>>>>> + * write_stats_prune_period - Set or report the period for
>>>>>>> pruning
>>>>>>> + *			      old per-client/per-export stats entries,
>>>>>>> + *			      in seconds.
>>>>>>> + *
>>>>>>> + * Input:
>>>>>>> + *			buf:		ignored
>>>>>>> + *			size:		zero
>>>>>>> + *
>>>>>>> + * OR
>>>>>>> + *
>>>>>>> + * Input:
>>>>>>> + * 			buf:		C string containing an unsigned
>>>>>>> + * 					integer value representing the new value
>>>>>>> + *			size:		non-zero length of C string in @buf
>>>>>>> + * Output:
>>>>>>> + *	On success:	passed-in buffer filled with '\n'-terminated C
>>>>>>> string
>>>>>>> + *			containing numeric value of the current setting
>>>>>>> + *			return code is the size in bytes of the string
>>>>>>> + *	On error:	return code is zero or a negative errno value
>>>>>>> + */
>>>>>>
>>>>>> Just an idle remark, don't worry about this for now, but: we  
>>>>>> might
>>>>>> want
>>>>>> to rein in this write_*() comment format a little some day.  A
>>>>>> lot of
>>>>>> the content seems duplicated.
>>>>
>>>> I disagree.
>>>
>>> How?  The below seems to be an arguing against *removing* the
>>> comments,
>>> or removing information from them, neither of which I'd be in favor
>>> of.
>>
>> Then I misunderstood what you meant by "rein in".
>>
>> The apparent content duplication is because these functions are all
>> slightly different.  What we had before was a single description of  
>> the
>> return values at the top of the files that more or less fit each proc
>> file, but didn't precisely fit any but the oldest.
>>
>> (Responding a bit to Greg) IMO highlighting the differences instead
>> means a person trying to understand this interface has to read the  
>> whole
>> damn nfsctl.c file instead of looking at the one piece s/he is
>> interested in.  This is documentation, not code, so I think a little
>> text duplication is OK or even actually preferred.
>
> Agreed, and I agree that nobody should have to read the whole file.   
> But
> appropriate cross-references ("foo() behaves like bar() except...")
> could prevent that.  As long as we don't require following too many  
> such
> references, I think the burden of tracking following references  
> would be
> outweighed by the benefits of more concise descriptions.

I'm OK with more brevity in these comments as long as we recognize  
that the devil is in the details.  We should preserve the specificity  
of the API descriptions.

I think it was you who was complaining recently about knowing whether  
a \n or a \0 is expected at the end of some of these strings.  ;-)

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
