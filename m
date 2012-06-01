Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:46431 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965519Ab2FAQxF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 12:53:05 -0400
Message-ID: <4FC8F36D.5040504@cora.nwra.com>
Date: Fri, 01 Jun 2012 10:53:01 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Spurious rpc.idmapd nss_getpwnam: name 'nobody' does not map
 into domain messages
References: <loom.20120601T174414-583@post.gmane.org>  <1338566283.2774.19.camel@lade.trondhjem.org>  <4FC8ED22.40508@cora.nwra.com> <1338568876.2774.25.camel@lade.trondhjem.org>
In-Reply-To: <1338568876.2774.25.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2012 10:41 AM, Myklebust, Trond wrote:
> On Fri, 2012-06-01 at 10:26 -0600, Orion Poplawski wrote:
>> So absence of @ indicates no need to translate locally, so don't complain
>> about it.  So how about this:
>>
>> --- ./libnfsidmap-0.25/nss.c.nobody     2011-12-05 13:28:10.000000000 -0700
>> +++ ./libnfsidmap-0.25/nss.c    2012-06-01 10:23:53.408603517 -0600
>> @@ -177,9 +177,10 @@
>>           IDMAP_LOG(4, ("nss_getpwnam: name '%s' domain '%s': "
>>                     "resulting localname '%s'\n", name, domain, localname));
>>           if (localname == NULL) {
>> -               IDMAP_LOG(0, ("nss_getpwnam: name '%s' does not map "
>> -                       "into domain '%s'\n", name,
>> -                       domain ? domain : "<not-provided>"));
>> +               if (strchr(name, '@' != NULL)
>> +                       IDMAP_LOG(0, ("nss_getpwnam: name '%s' does not map "
>> +                               "into domain '%s'\n", name,
>> +                               domain ? domain : "<not-provided>"));
>>                   goto err_free_buf;
>>           }
>
> ACK. That looks about right...
>

Another possibility is that we shouldn't even be calling nss_getpwnam() in the 
first place in this case, but I don't know the code well enough to pursue that 
or if it's worth it.


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
