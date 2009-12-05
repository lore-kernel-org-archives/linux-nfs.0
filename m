From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 5 Dec 2009 14:03:20 -0500
Message-ID: <89c397150912051103y52ca3ef1ua238cb7f2887be81@mail.gmail.com>
References: <1259965498.2825.5.camel@localhost>
	 <273FE88A07F5D445824060902F70034408A1A330@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:34258 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932873AbZLETDO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 14:03:14 -0500
Received: by yxe17 with SMTP id 17so2933845yxe.33
        for <linux-nfs@vger.kernel.org>; Sat, 05 Dec 2009 11:03:20 -0800 (PST)
In-Reply-To: <273FE88A07F5D445824060902F70034408A1A330-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK - I'll take a look...

-->Andy

On Sat, Dec 5, 2009 at 2:05 AM, Labiaga, Ricardo
<Ricardo.Labiaga@netapp.com> wrote:
> I'm seeing a problem with the bits in the nfs-for-next branch when I run
> v4.1.  If a bad session is received after a server reboot, the client
> issues a flood of sequence requests.  The sequence RPCs contain the last
> sequenceID from the previous session with the new sessionID.  This is
> repeated over and over until you ctrl-C the triggering process.  The
> server replies with sequence misordered, but the client issues the exact
> same RPC over and over.
>
> Also to note is that right after the session is destroyed, the client
> will issue sequence requests with sessionID of 0 right before the create
> session succeeds.
>
> - ricardo
>
>
>> -----Original Message-----
>> From: Myklebust, Trond
>> Sent: Friday, December 04, 2009 2:25 PM
>> To: Adamson, Andy
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
>>
>> On Fri, 2009-12-04 at 17:01 -0500, Trond Myklebust wrote:
>> > Those look good to me. I had to fix them up a bit in order to have
> them
>> > apply on top of the nfs-for-next branch, but nothing major.
>>
>> I figured I might as well push them out immediately. They compile, and
>> they don't seem to have any adverse effects on the NFSv4 stuff.
>>
>> You can find them as the nfs-for-next branch on
>> git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
>>
>> Cheers
>>   Trond
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
