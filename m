From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Wed, 12 Nov 2008 11:20:45 -0500
Message-ID: <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com> <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com> <491AFE09.2010803@bull.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:31106 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbYKLQVZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:21:25 -0500
In-Reply-To: <491AFE09.2010803@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 12, 2008, at 11:02 AM, Le Rouzic wrote:
>
> Hi,
> Sorry for not answering earlier but I am back to-day after some days =
=20
> out
> of my office.
> I plan to do also some run-time  testing with your new tree.

Thanks for testing, and don't be afraid to review the patches too.  :-)

> Regards
>
> Chuck Lever a =E9crit :
>
>>
>> On Nov 10, 2008, at 12:15 AM, Varun Chandramohan wrote:
>>
>>> Chuck Lever wrote:
>>>
>>>> Hi Aime, Varun-
>>>>
>>>> Bruce asked me to collect server-side IPv6 patches for upstream.
>>>> I've collected the patches that have been posted on the list, and
>>>> added some fixes of my own.
>>>>
>>>> Can you have a look at
>>>>
>>>> http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary
>>>>
>>>> tag cel-ipv6-10292008
>>>>
>>>> These have been build tested, but I haven't done any run-time
>>>> testing yet.
>>>>
>>>> --
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>> Hi Chuck,
>>>
>>>               I just realized that i forgot to update you about the
>>> test result of your tree. I found NFSv4 over ipv6 working well. So
>>> it can be pulled into the mainline soon.
>>
>>
>> Thanks for testing!
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-=20
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
>
> --
> -----------------------------------------------------------------
> Company : Bull, Architect of an Open World TM (www.bull.com)
> Name    : Aime Le Rouzic
> Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
> E-Mail  : aime.le-rouzic@bull.net
> Phone   : 33 (4) 76.29.75.51
> Fax     : 33 (4) 76.29.75.18
> -----------------------------------------------------------------
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



