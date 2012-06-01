Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:45899 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759188Ab2FAQ0P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 12:26:15 -0400
Message-ID: <4FC8ED22.40508@cora.nwra.com>
Date: Fri, 01 Jun 2012 10:26:10 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Spurious rpc.idmapd nss_getpwnam: name 'nobody' does not map
 into domain messages
References: <loom.20120601T174414-583@post.gmane.org> <1338566283.2774.19.camel@lade.trondhjem.org>
In-Reply-To: <1338566283.2774.19.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2012 09:58 AM, Myklebust, Trond wrote:
> On Fri, 2012-06-01 at 15:53 +0000, Orion Poplawski wrote:
>> I'm seeing a fair number of these messages on our file server:
>>
>> Jun  1 09:37:58 alexandria rpc.idmapd[28890]: nss_getpwnam: name 'nobody' does
>> not map into domain 'cora.nwra.com'
>>
>> I think they are coming from accessing files on another file server that are
>> owned by an unknown uid (user left and was removed from the user database).
>> These files end up owned by "nobody" (as expected) on the remote system:
>>
>> drwxr-xr-x.  7 nobody nwra 4096 Mar 15  2010 analysis_data
>>
>> Now, this seems like a perfectly normal operation and so shouldn't generate a
>> system log message.  First two possible fixes I can think of:
>>
>> - Should the remote system send the username as "nobody@cora.nwra.com" instead
>> of just "nobody"?
>
> No. According to section 5.8 of RFC3530, it should use the name "nobody"
> without a domain, and the idmapper should be mapping that string to the
> anonymous user (i.e. uid -2).
>

Well, it's mapping it to "nobody" id 99:

drwxr-xr-x.  7 99 1001 4096 Mar 15  2010 analysis_data

Okay, so no domain.  Also according to 5.8:

    In the case where there is no translation available to the client or
    server, the attribute value must be constructed without the "@".
    Therefore, the absence of the @ from the owner or owner_group
    attribute signifies that no translation was available at the sender
    and that the receiver of the attribute should not use that string as
    a basis for translation into its own internal format.  Even though
    the attribute value can not be translated, it may still be useful.
    In the case of a client, the attribute string may be used for local
    display of ownership.

So absence of @ indicates no need to translate locally, so don't complain 
about it.  So how about this:

--- ./libnfsidmap-0.25/nss.c.nobody     2011-12-05 13:28:10.000000000 -0700
+++ ./libnfsidmap-0.25/nss.c    2012-06-01 10:23:53.408603517 -0600
@@ -177,9 +177,10 @@
         IDMAP_LOG(4, ("nss_getpwnam: name '%s' domain '%s': "
                   "resulting localname '%s'\n", name, domain, localname));
         if (localname == NULL) {
-               IDMAP_LOG(0, ("nss_getpwnam: name '%s' does not map "
-                       "into domain '%s'\n", name,
-                       domain ? domain : "<not-provided>"));
+               if (strchr(name, '@' != NULL)
+                       IDMAP_LOG(0, ("nss_getpwnam: name '%s' does not map "
+                               "into domain '%s'\n", name,
+                               domain ? domain : "<not-provided>"));
                 goto err_free_buf;
         }



-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
