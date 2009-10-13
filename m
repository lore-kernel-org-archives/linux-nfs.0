From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils-1.2.0: insecure option and port range checking.
Date: Tue, 13 Oct 2009 14:09:48 -0400
Message-ID: <4AD4C26C.2030002@RedHat.com>
References: <ADD0E404-49A2-49AA-A3A1-A7065243E14E@openrbg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933970AbZJMSKa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 14:10:30 -0400
In-Reply-To: <ADD0E404-49A2-49AA-A3A1-A7065243E14E-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/13/2009 01:56 PM, Robert Gordon wrote:
> 
> I noticed that the insecure option validates that the client port is a
> subset of IPPORT_RESERVED as opposed to just validating it is a valid
> reserved port. The following proposed patch would correct that issue.
> Would anyone care to comment ? ..
> 
> # diff utils/mountd/auth.c utils/mountd/auth.c.orig
> 171a172
>>             (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
> 
What version of nfs-utils are you using and please generate a proper
patch (via gendiff) with a proper 'Signed-off-by:' label...

tia,

steved.
