Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434AbaHGNb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 09:31:26 -0400
Message-ID: <53E37FA8.5010402@RedHat.com>
Date: Thu, 07 Aug 2014 09:31:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jurjen Bokma <j.bokma@rug.nl>, linux-nfs@vger.kernel.org
Subject: Re: Patch: select non-conventional principal in gssd
References: <53E242E9.1050106@rug.nl> <53E36741.2010907@RedHat.com> <53E378A6.8040401@rug.nl>
In-Reply-To: <53E378A6.8040401@rug.nl>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2014 09:01 AM, Jurjen Bokma wrote:
> On 08/07/2014 01:47 PM, Steve Dickson wrote:
>>
>> On 08/06/2014 10:59 AM, Jurjen Bokma wrote:
>>> HiAll,
>>>
>>> I have a patch to utils/gssd/krb5_util.c that enables kerberized NFS
>>> mounts to succeed even if the principal is not <HOSTNAME>$.
>>>
>>> It works by reading another principal name from the [appdefaults]
>>> section of krb5.conf:
>>>
>>> [appdefaults]
>>> nfs = {
>>>     ad_principal_name = 129.125.39.115$
>>> }
>>>
>>> Patch is attached. Would you please incorporate it in the source if you
>>> find it useful?
>>> Sorry if I'm asking in the wrong place.
>> A couple things.... 
>>
>> One please inline your patche in your email, not attach them
>> as suggested in https://www.kernel.org/doc/Documentation/SubmittingPatches
>> Inlining makes it easier to review... 
> I'm sorry. Also for not using the proper command, not choosing the
> proper subsystem, and a couple more mistakes.
Unfortunately you still don't have a proper  Signed-off-by: 
as described in the above documentation... So you will 
need to re-post the patch... but... 

So lets start from the beginning.... 

When you commit the patch to your git tree do:
   git commit -s -a # this will automatically added the Signed-off-by:

Next create the patch with:
   git format-patch -1

Finally send the patch to list with
   git send-email \
       --to "Steve Dickson <steved@redhat.com>" \
       --cc "Linux NFS Mailing list <linux-nfs@vger.kernel.org>" \
       *.patch 

Note: git send-email has a --dry-run that will test the sending
without actually sending it... I would suggest you always do a 
test sending... Just to make sure things are going in the 
right direction! ;-) 

steved.
