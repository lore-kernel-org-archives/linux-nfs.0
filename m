From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: question about nfs41 features
Date: Thu, 23 Sep 2010 17:09:01 -0400
Message-ID: <AANLkTin-JSojTi51PcxVAQCDkJj1B-pX_SCKY8i1GBMu@mail.gmail.com>
References: <AANLkTinvrHsQmcLCpt99dE1nU0md8zfwsh4vP8JRBJT6@mail.gmail.com>
	<20100923210440.GC14610@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41089 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635Ab0IWVJD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 17:09:03 -0400
Received: by wwd20 with SMTP id 20so185342wwd.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Sep 2010 14:09:02 -0700 (PDT)
In-Reply-To: <20100923210440.GC14610@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 23, 2010 at 5:04 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Thu, Sep 23, 2010 at 02:30:49PM -0400, Olga Kornievskaia wrote:
>> I would greatly appreciate it I can get a reply from NFS41 server
>> implementers out there on the subject of whether or not the followin=
g
>> feature are (a) currently implemented by your server, (b) will be
>> implemented soon (1year), (c) having interest in being implemented
>> within the next few years and (d) are so low in priority that could =
be
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
> I'm guessing (c) or (d). =A0(I'd be happier if SSV were a higher prio=
rity,
> but oh well.)
>
>> trunking (session or clientid)
>
> (b)
>
>> segmented file layouts
>>
>> recall of file layouts
>> cb_notify_deviceid
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
> implementors, so you may want to ask on nfsv4@ietf.org or ask people =
at
> the bakeathon.

Thank you Bruce. Thomas Haynes has also pointed this mistake out to me
and I posted to the ietf list.
