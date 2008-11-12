From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Wed, 12 Nov 2008 17:02:17 +0100
Message-ID: <491AFE09.2010803@bull.net>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com> <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:56193 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbYKLQDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:03:43 -0500
In-Reply-To: <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,
Sorry for not answering earlier but I am back to-day after some days ou=
t=20
of my office.
I plan to do also some run-time  testing with your new tree.

Regards



Chuck Lever a =E9crit :

>
> On Nov 10, 2008, at 12:15 AM, Varun Chandramohan wrote:
>
>> Chuck Lever wrote:
>>
>>> Hi Aime, Varun-
>>>
>>> Bruce asked me to collect server-side IPv6 patches for upstream.  =20
>>> I've collected the patches that have been posted on the list, and =20
>>> added some fixes of my own.
>>>
>>> Can you have a look at
>>>
>>>  http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary
>>>
>>>  tag cel-ipv6-10292008
>>>
>>> These have been build tested, but I haven't done any run-time =20
>>> testing yet.
>>>
>>> --=20
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>
>> Hi Chuck,
>>
>>                I just realized that i forgot to update you about the=
 =20
>> test result of your tree. I found NFSv4 over ipv6 working well. So =20
>> it can be pulled into the mainline soon.
>
>
> Thanks for testing!
>
> --=20
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> --=20
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

