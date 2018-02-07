Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa06-05.prod.phx3.secureserver.net ([173.201.192.106]:39374
        "EHLO p3plsmtpa06-05.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932106AbeBGAWc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Feb 2018 19:22:32 -0500
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <6bd33601-2c59-3d19-ece2-878b885c2940@RedHat.com>
 <C44A49E5-FEA5-482F-B945-BD967841F2FF@oracle.com>
 <0f9b020a-4c65-4b3b-42b2-81f8f9ee0941@RedHat.com>
 <6EF07D03-7F1C-43D1-963B-ED28AD614BF4@oracle.com>
 <02863316-1c99-182c-b19e-cc1aff46c382@talpey.com>
 <144B9B35-E12F-43B3-8725-CEF670F4C334@oracle.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <2a63e8fd-c62a-6e56-70a5-ff3852287d1d@talpey.com>
Date: Tue, 6 Feb 2018 19:15:12 -0500
MIME-Version: 1.0
In-Reply-To: <144B9B35-E12F-43B3-8725-CEF670F4C334@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/6/2018 1:36 PM, Chuck Lever wrote:
> 
> 
>> On Feb 6, 2018, at 1:22 PM, Tom Talpey <tom@talpey.com> wrote:
>>
>> On 2/6/2018 12:34 PM, Chuck Lever wrote:
>>> mountd can and should use a dynamic port assignment, IMO.
>>> It doesn't have to use 20048.
>>
>> Speaking of 20048, does anyone know why Nico made this assignment?
>> Apart from making it well-known for firewalls, what system(s)
>> actually required it? I don't recall it ever being discussed.
>> Using it is certainly not required, since portmap resolves it.
>>
>> https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.txt
>>
>> ++ mountd             20048       tcp    NFS mount protocol [Nicolas_Williams]                                    [Nicolas_Williams]                                        2010-08-09
>> ++ mountd             20048       udp    NFS mount protocol [Nicolas_Williams]                                    [Nicolas_Williams]                                        2010-08-09
> 
> Actually my first active interaction with the nfsv4 WG was at the
> IETF meeting in Montreal in late July of 2010. So I can't say that
> I have any memory of why this was done. It might be a question that
> can be answered by someone on nfsv4@ietf.org.

Sure, or Nico directly. What I was wondering is why nfs-utils seems
to have implemented it? Surely there was a reason?

Tom.
