Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:55992 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab3JJOmg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Oct 2013 10:42:36 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        "Weston Andros Adamson" <dros@netapp.com>
Subject: Re: DoS with NFSv4.1 client
Date: Thu, 10 Oct 2013 14:42:27 +0000
Message-ID: <42952959-D598-475B-9F5E-ACDF50FF7114@netapp.com>
References: <1667669326.580689.1381351712928.JavaMail.zimbra@desy.de>
 <1232423514.586176.1381399016371.JavaMail.zimbra@desy.de>
 <24F8F3E5-578D-43C1-83B8-F3310526D4AE@netapp.com>
 <22165921.590399.1381413800631.JavaMail.zimbra@desy.de>
 <194A4163-11C3-453B-9E3C-6B1460A7E57A@netapp.com>
In-Reply-To: <194A4163-11C3-453B-9E3C-6B1460A7E57A@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry - I answered this email thread from my netapp account and didn't 'cc the lists.

-->Andy

On Oct 10, 2013, at 10:19 AM, "Adamson, Andy" <William.Adamson@netapp.com>
 wrote:

> 
> On Oct 10, 2013, at 10:03 AM, "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> wrote:
> 
>> Not only. As was able to reproduce it and fix on the server,
>> we see that at the end client will send only one CLOSE.
> 
> I don't understand. If it is fixed on the server, then the client will send an OPEN, get an openstateid - say OS-1 , do a LAYOUTGET, and READ to the DS using OS-1. The server then returns BAD stateid on the READ. 
> 
> The client then goes through stateid recovery, which means issuing another OPEN to get OS-2, which is then used for the DS READS
> 
> the client then CLOSE the file using OS-2. 
> 
> Are you saying that the client does not close using OS-1? Note that is impossible, as OS-1 is a BAD stateid….
> 
> -->Andy
> 
>> 
>> Tigran.
>> 
>> ----- Original Message -----
>>> From: "Andy Adamson" <William.Adamson@netapp.com>
>>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
>>> Sent: Thursday, October 10, 2013 3:55:55 PM
>>> Subject: Re: DoS with NFSv4.1 client
>>> 
>>> OK - so it's a server bug,
>>> 
>>> -->Andy
>>> 
>>> On Oct 10, 2013, at 5:56 AM, "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>>> wrote:
>>> 
>>>> 
>>>> 
>>>> Today we was 'luck' to have such situation at day time.
>>>> Here is what happens:
>>>> 
>>>> The client sends an OPEN and gets an open state id.
>>>> This is followed by LAYOUTGET ... and READ to DS.
>>>> At some point, server returns back BAD_STATEID.
>>>> This triggers client to issue a new OPEN and use
>>>> new open stateid with READ request to DS. As new
>>>> stateid is not known to DS, it keeps returning
>>>> BAD_STATEID and becomes an infinite loop.
>>>> 
>>>> Regards,
>>>> Tigran.
>>>> 
>>>> 
>>>> 
>>>> ----- Original Message -----
>>>>> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
>>>>> To: linux-nfs@vger.kernel.org
>>>>> Cc: "Andy Adamson" <william.adamson@netapp.com>, "Steve Dickson"
>>>>> <steved@redhat.com>
>>>>> Sent: Wednesday, October 9, 2013 10:48:32 PM
>>>>> Subject: DoS with NFSv4.1 client
>>>>> 
>>>>> 
>>>>> Hi,
>>>>> 
>>>>> last night we got a DoS attack with one of the NFS clients.
>>>>> The farm node, which was accessing data with pNFS,
>>>>> went mad and have tried to kill dCache NFS server. As usually
>>>>> this have happened over night and we was not able to
>>>>> get a network traffic or bump the debug level.
>>>>> 
>>>>> The symptoms are:
>>>>> 
>>>>> client starts to bombard the MDS with OPEN requests. As we see
>>>>> state created on the server side, the requests was processed by
>>>>> server. Nevertheless, for some reason, client did not like it. Here
>>>>> is the result of mountstats:
>>>>> 
>>>>> OPEN:
>>>>> 	17087065 ops (99%) 	1 retrans (0%) 	0 major timeouts
>>>>> 	avg bytes sent per op: 356	avg bytes received per op: 455
>>>>> 	backlog wait: 0.014707 	RTT: 4.535704 	total execute time: 4.574094
>>>>> 	(milliseconds)
>>>>> CLOSE:
>>>>> 	290 ops (0%) 	0 retrans (0%) 	0 major timeouts
>>>>> 	avg bytes sent per op: 247	avg bytes received per op: 173
>>>>> 	backlog wait: 308.827586 	RTT: 1748.479310 	total execute time:
>>>>> 	2057.365517
>>>>> 	(milliseconds)
>>>>> 
>>>>> 
>>>>> As you can see there is a quite a big difference between number of open
>>>>> and
>>>>> close requests.
>>>>> The same picture we can see on the server side as well:
>>>>> 
>>>>> NFSServerV41 Stats:                   average±stderr(ns)       min(ns)
>>>>> max(ns)            Sampes
>>>>> DESTROY_SESSION                          26056±4511.89        13000
>>>>> 97000                17
>>>>> OPEN                                    1197297±  0.00       816000
>>>>> 31924558000          54398533
>>>>> RESTOREFH                                     0±  0.00            0
>>>>> 25018778000          54398533
>>>>> SEQUENCE                                   1000±  0.00         1000
>>>>> 26066722000          55601046
>>>>> LOOKUP                                  4607959±  0.00       375000
>>>>> 26977455000             32118
>>>>> GETDEVICEINFO                             13158±100.88         4000
>>>>> 655000             11378
>>>>> CLOSE                                  16236211±  0.00         5000
>>>>> 21021819000             20420
>>>>> LAYOUTGET                             271736361±  0.00     10003000
>>>>> 68414723000             21095
>>>>> 
>>>>> The last column is the number of requests.
>>>>> 
>>>>> This is with RHEL6.4 as the client. By looking at the code,
>>>>> I can see a loop at nfs4proc.c#nfs4_do_open() which can be
>>>>> the cause of the problem. Nevertheless, I can't
>>>>> fine any reason why this look turned into an 'infinite' one.
>>>>> 
>>>>> At the and our server ran out of memory and we have returned
>>>>> NFSERR_SERVERFAULT to the client. This triggered client to
>>>>> reestablish the session and all open state ids was
>>>>> invalidated and cleaned up.
>>>>> 
>>>>> I am still trying to reproduce this behavior (on client
>>>>> and server) and any hint is welcome.
>>>>> 
>>>>> Tigran.
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>> 
>>> 
>>> 
> 

