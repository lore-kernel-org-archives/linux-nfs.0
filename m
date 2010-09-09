From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] libexport.a: Refactor init_netmask()
Date: Thu, 9 Sep 2010 13:03:12 -0400
Message-ID: <AC20E599-9576-4F97-97BD-8E9B2E3E3F87@oracle.com>
References: <20100902192350.1755.66184.stgit@matisse.1015granger.net> <4C88F16B.10802@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22407 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab0IIRDg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 13:03:36 -0400
In-Reply-To: <4C88F16B.10802-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On Sep 9, 2010, at 10:38 AM, Steve Dickson wrote:

> 
> On 09/02/2010 03:23 PM, Chuck Lever wrote:
>> Instead of a single function that can handle both AF_INET and AF_INET6
>> addresses, two separate functions might be cleaner.
>> 
>> The original plan was to keep code redundancy at a minimum, but the
>> resulting code was cumbersome at best.  I think I've traded a little
>> extra code for something that will be much easier to read, understand,
>> and maintain.
>> 
>> I've also eliminated the "#if / #endif" instances inside the functions.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
> Committed...

This (and the RDMA patches) appears in nfs-utils-exp.git, but not in nfs-utils.git.

For my development tree, I pull from the latter.  Should I pull from nfs-utils-exp instead?

-- 
chuck[dot]lever[at]oracle[dot]com




