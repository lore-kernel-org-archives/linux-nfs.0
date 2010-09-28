Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41189 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752402Ab0I1J1W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 05:27:22 -0400
Message-ID: <4CA1B4F3.7030106@panasas.com>
Date: Tue, 28 Sep 2010 11:27:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: question about nfs41 features
References: <AANLkTinvrHsQmcLCpt99dE1nU0md8zfwsh4vP8JRBJT6@mail.gmail.com> <20100923210440.GC14610@fieldses.org>
In-Reply-To: <20100923210440.GC14610@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-23 23:04, J. Bruce Fields wrote:
> On Thu, Sep 23, 2010 at 02:30:49PM -0400, Olga Kornievskaia wrote:
>> I would greatly appreciate it I can get a reply from NFS41 server
>> implementers out there on the subject of whether or not the following
>> feature are (a) currently implemented by your server, (b) will be
>> implemented soon (1year), (c) having interest in being implemented
>> within the next few years and (d) are so low in priority that could be
>> said: will never be implemented.
> 
> This could change depending on interest, of course, but:
> 
>> volatile handles
>> named attributes
> 
> Probably both (d).
> 
>> directory delegations
>> SSV
> 
> I'm guessing (c) or (d).  (I'd be happier if SSV were a higher priority,
> but oh well.)
> 
>> trunking (session or clientid)
> 
> (b)
> 
>> segmented file layouts
>>

maybe (c)

>> recall of file layouts
>> cb_notify_deviceid

This is already implemented in the linux-pnfs tree.

Benny

> 
> Not sure.
> 



>> cb_getattr
> 
> (c)
> 
>> cb_recall_slot
>> cb_notify_lock
> 
> Probably both (c).
> 
> This list doesn't necessarily get you anyone other than linux
> implementors, so you may want to ask on nfsv4@ietf.org or ask people at
> the bakeathon.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
