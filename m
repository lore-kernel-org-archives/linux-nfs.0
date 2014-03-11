Return-Path: linux-nfs-owner@vger.kernel.org
Received: from engine03-30064-2.icritical.com ([93.159.202.47]:54628 "HELO
	engine03-30064-2.icritical.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752787AbaCKIto (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2014 04:49:44 -0400
Received: from engine03-30064-2.icritical.com ([127.0.0.1])
 by localhost (engine03-30064-2.icritical.com [127.0.0.1]) (amavisd-new, port 10024)
 with SMTP id 14252-06 for <linux-nfs@vger.kernel.org>;
 Tue, 11 Mar 2014 08:49:36 +0000 (GMT)
Message-ID: <531ECE21.5070601@pml.ac.uk>
Date: Tue, 11 Mar 2014 08:49:37 +0000
From: Ben Taylor <benj@pml.ac.uk>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: NFS4 patch 08/20 (BAD_SEQID recovery)
References: <53199445.3010808@pml.ac.uk> <69B89FEE-5B58-468F-95CE-B384033B2E65@primarydata.com> <531DF5B4.9050001@pml.ac.uk> <0BE71BDE-FFFB-4124-B037-8ABBD5C20455@primarydata.com>
In-Reply-To: <0BE71BDE-FFFB-4124-B037-8ABBD5C20455@primarydata.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/03/14 23:23, Trond Myklebust wrote:
> 
> On Mar 10, 2014, at 13:26, Ben Taylor <benj@pml.ac.uk> wrote:
> 
>> Hi Trond
>>
>> On 07/03/14 13:05, Trond Myklebust wrote:
>>>> Can anyone tell me what happened to this patch please? Was it lost or
>>>>> superseded?
>>> It was superseded by commit 95b72eb0bdef6 (NFSv4: Ensure we do not reuse open owner names), which is available in linux 3.4 and newer.
>>
>> Many thanks. That's a puzzle then, because we're running 3.9 and up and
>> already have that patch (I've checked).
>>
>> I've attached my Wireshark dump (or at least a subset of it -
>> unfortunately I don't have the original call, the dump I've got is all
>> the same) - don't know if this tells you anything it doesn't tell me?
>> I'm not exactly experienced at reading these things!
>>
> 
> It looks as if the client is trying to convert a delegation into an open stateid as part of returning that delegation, but the server is disputing the sequence id value.
> What server is this?

It's our main user-space file server, running CentOS 6.5, kernel
version... ah. Kernel version 2.6, I only checked the client version
previously.

That's probably the issue then. Sorry, thanks for your help!

Regards
Ben

-- 
Ben Taylor <benj@pml.ac.uk>, http://rsg.pml.ac.uk/
Remote Sensing Group, Plymouth Marine Laboratory
Tel: +44 (0)1752 633432, Fax: +44 (0)1752 633101


Please visit our new website at www.pml.ac.uk and follow us on Twitter  @PlymouthMarine

Plymouth Marine Laboratory (PML) is a company limited by guarantee registered in England & Wales, company number 4178503. Registered Charity No. 1091222. Registered Office: Prospect Place, The Hoe, Plymouth  PL1 3DH, UK. 

This message is private and confidential. If you have received this message in error, please notify the sender and remove it from your system. You are reminded that e-mail communications are not secure and may contain viruses; PML accepts no liability for any loss or damage which may be caused by viruses.

