Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:58258 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247Ab2DLOfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 10:35:05 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id q3CEZ0vt012909
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 16:35:00 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id q3CEZ0Tf021706
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 16:35:00 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.cdc.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id q3CEZ0WP003001
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 16:35:00 +0200
Message-ID: <4F86E813.3010200@cea.fr>
Date: Thu, 12 Apr 2012 16:34:59 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: How to manage EDQUOT on the server side
References: <4F86E4E0.8000703@cea.fr> <20120412142946.GB29891@us.ibm.com>
In-Reply-To: <20120412142946.GB29891@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Malahal Naineni a écrit :
> Are you using Linux client?
Yes.

>  I think there is a bug where the client
> reports EIO rather than QUOTA/NOSPC errors under some circumstances.
>   
Do you have more informations about those circumstances ? I just ran 
"dd" until I exceed my data quota's hard limit.

    Regards

       Philippe

> I didn't know about client looping on the same WRITE call though!
>
> Thanks, Malahal.
>
> DENIEL Philippe [philippe.deniel@cea.fr] wrote:
>   
>> Hi,
>>
>> I am currently busy with implementing quota management in my nfs
>> server (nfs-ganesha).
>> I have efficient way to make NFS3_WRITE detecting an IO that exceeds
>> data quota, and use that to return NFS3ERR_DQUOT.
>> Wireshark shows me that nfs reply contains NFS3ERR_DQUOT, but the
>> client starts looping on the same WRITE call. By the end, by test
>> application (a simple 'dd') end with "I/O Error".
>> Did I miss something when implementing this ?
>> I had no rquotad running for the share at the time the test was
>> running, should I have a co-related rquotad running as well ?
>>
>>    Regards
>>
>>       Philippe
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>     
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

