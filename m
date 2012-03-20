Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:41669 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907Ab2CTOge (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 10:36:34 -0400
Message-ID: <4F6895EE.8090609@rath.org>
Date: Tue, 20 Mar 2012 10:36:30 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Rick Macklem <rmacklem@uoguelph.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
References: <716104306.1267694.1332195933869.JavaMail.root@erie.cs.uoguelph.ca>	 <4F688655.1090703@rath.org> <1332251753.2963.17.camel@lade.trondhjem.org>
In-Reply-To: <1332251753.2963.17.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/20/2012 09:55 AM, Myklebust, Trond wrote:
> On Tue, 2012-03-20 at 09:29 -0400, Nikolaus Rath wrote:
>> On 03/19/2012 06:25 PM, Rick Macklem wrote:
>>> Nikolaus Rath wrote:
>>> ps: Also, although it's not very relevant, getting the MAC address of
>>>     the first ethernet interface isn't easy in FreeBSD. I have no idea
>>>     if the same is true of Linux. (I'd also be worried that "first"
>>>     might not be fixed?)
>>
>> It doesn't need to be the same interface all the time, I just meant the
>> first as in not a specific one.
> 
> Yes it does have to be the same interface all the time. Otherwise the
> server cannot tell that this is the same client booting up again.

The likelihood of the interface order changing is certainly much lower
than the likelihood of the IP address changing (which I understand is
currently used for the clientid), so the situation would still improve.


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
