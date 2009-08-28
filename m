From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: 2008 mountd clean-up patch
Date: Fri, 28 Aug 2009 09:43:09 -0400
Message-ID: <6A9AD7A7-1727-4AB5-BDD9-23AFE71B4208@oracle.com>
References: <1F6E13E6-2D6F-4B80-B4E6-1B251012AF5A@oracle.com> <1251410478.32255.14.camel@dyn9047022153>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40840 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbZH1ONw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2009 10:13:52 -0400
In-Reply-To: <1251410478.32255.14.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 27, 2009, at 6:01 PM, Frank Filz wrote:
> On Thu, 2009-08-27 at 15:34 -0400, Chuck Lever wrote:
>> I'm looking at a 2008 nfs-utils clean up done in commit 7a817c45.  It
>> has this hunk in it:
>>
>> @@ -111,7 +111,7 @@ void auth_unix_ip(FILE *f)
>>         else if (client)
>>                 qword_print(f, *client?client:"DEFAULT");
>>         qword_eol(f);
>> -       xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, *client?
>> client: "DEFAULT");
>> +       xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?
>> client: "DEFAULT");
>>
>>         if (client) free(client);
>>         free(he);
>>
>> You changed the '*client ? client : "DEFAULT"' expression in the
>> xlog() call, but not in the qword_print() call right above it.  Which
>> of these is correct, and why do they need to be different from each
>> other?
>>
>> Seems to me _both_ should be 'client ? client : "DEFAULT"' (ie.
>> without the dereference).
>
> There would be no point to not dereferencing client, it has already  
> been
> checked for NULL by "else if (client)". What it is doing is if the
> client string is empty, it is printing "DEFAULT", and if the client
> string is NULL, then it prints nothing.
>
> Perhaps the xlog should be:
>
>
> 	if (client)
> 		xlog(D_CALL, "auth_unix_ip: client %p '%s', client, *client? 
> client: "DEFAULT");
> 	else
> 		xlog(D_CALL, "auth_unix_ip: client NULL");

To confirm, then, the fix in 7a817c45 is bogus?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



