Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-08.prod.phx3.secureserver.net ([173.201.193.237]:32850
        "EHLO p3plsmtpa09-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753213AbeBFS3d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Feb 2018 13:29:33 -0500
From: Tom Talpey <tom@talpey.com>
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
To: Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <6bd33601-2c59-3d19-ece2-878b885c2940@RedHat.com>
 <C44A49E5-FEA5-482F-B945-BD967841F2FF@oracle.com>
 <0f9b020a-4c65-4b3b-42b2-81f8f9ee0941@RedHat.com>
 <6EF07D03-7F1C-43D1-963B-ED28AD614BF4@oracle.com>
Message-ID: <02863316-1c99-182c-b19e-cc1aff46c382@talpey.com>
Date: Tue, 6 Feb 2018 13:22:12 -0500
MIME-Version: 1.0
In-Reply-To: <6EF07D03-7F1C-43D1-963B-ED28AD614BF4@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/6/2018 12:34 PM, Chuck Lever wrote:
> mountd can and should use a dynamic port assignment, IMO.
> It doesn't have to use 20048.

Speaking of 20048, does anyone know why Nico made this assignment?
Apart from making it well-known for firewalls, what system(s)
actually required it? I don't recall it ever being discussed.
Using it is certainly not required, since portmap resolves it.

https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.txt

++ mountd             20048       tcp    NFS mount protocol 
[Nicolas_Williams]                                    [Nicolas_Williams] 
                                        2010-08-09
++ mountd             20048       udp    NFS mount protocol 
[Nicolas_Williams]                                    [Nicolas_Williams] 
                                        2010-08-09

Tom.
