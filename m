From: Amit Gud <agud@akamai.com>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in milliseconds
Date: Wed, 10 Jun 2009 12:43:31 -0700
Message-ID: <4A300CE3.8080502@akamai.com>
References: <200906091832.50633.agud@akamai.com> <1244636844.24750.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, gud-OYTqUY/oFF8@public.gmane.org,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from prod-mail-xrelay01.akamai.com ([72.246.2.12]:46245 "EHLO
	prod-mail-xrelay01.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754620AbZFJTt7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2009 15:49:59 -0400
In-Reply-To: <1244636844.24750.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-06-09 at 18:32 -0700, Amit Gud wrote:
>> This patch adds 4 new NFS mount options(acdirminms, acdirmaxms, acregminms,
>> acregmaxms) converting already existing one into a millisecond resolution
>> instead of seconds.
>>
>> Also, modifies the mountstats output to milliseconds instead of seconds.
> 
> Why, exactly, do you need to control cache timeouts down to the
> millisecond level?
> 

The problem is to make the updates visible from one client to the other
in less than a second and turning off caching entirely has an
unacceptably high penalty.


AG
--
May the source be with you.
http://www.cis.ksu.edu/~gud
