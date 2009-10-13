From: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: nfs-utils-1.2.0: insecure option and port range checking.
Date: Tue, 13 Oct 2009 18:46:03 -0500
Message-ID: <78BA15DA-34B5-4CB8-9FFC-54E1DFB24D39@openrbg.com>
References: <ADD0E404-49A2-49AA-A3A1-A7065243E14E@openrbg.com> <4AD4C26C.2030002@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:58112 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753717AbZJMXrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 19:47:12 -0400
In-Reply-To: <4AD4C26C.2030002-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 13, 2009, at 1:09 PM, Steve Dickson wrote:

>
>
> On 10/13/2009 01:56 PM, Robert Gordon wrote:
>>
>> I noticed that the insecure option validates that the client port  
>> is a
>> subset of IPPORT_RESERVED as opposed to just validating it is a valid
>> reserved port. The following proposed patch would correct that issue.
>> Would anyone care to comment ? ..
>>
>> # diff utils/mountd/auth.c utils/mountd/auth.c.orig
>> 171a172
>>>            (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
>>
> What version of nfs-utils are you using and please generate a proper
> patch (via gendiff) with a proper 'Signed-off-by:' label...

Per the subject: it's 1.2.0 and here (hopefully) is the correct format  
(my first venture in generating a patch for linux, so it's a little  
new to me..)

Robert
-- 

Signed-off-by: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>

diff -up utils/mountd/auth.c.orig utils/mountd/auth.c
--- utils/mountd/auth.c.orig    2009-10-13 12:49:03.000000000 -0500
+++ utils/mountd/auth.c 2009-10-13 12:49:32.000000000 -0500
@@ -169,7 +169,6 @@ auth_authenticate_internal(char *what, s
                 }
         }
         if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
-                   (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
                      ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
                 *error = illegal_port;
                 return NULL;


