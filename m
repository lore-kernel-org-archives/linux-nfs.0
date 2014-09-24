Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686AbaIXPVx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 11:21:53 -0400
Message-ID: <5422E18E.2080905@RedHat.com>
Date: Wed, 24 Sep 2014 11:21:50 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jan Chaloupka <jchaloup@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd.man: mountd tcp wrappers support only NFS v2/v3
References: <20140923070733.25555.18292.stgit@unused-4-157.brq.redhat.com> <CAHQdGtRZA89spXkGWxoDyd8dRt-f9wfnfuz=rACsMe3bSa_meA@mail.gmail.com>
In-Reply-To: <CAHQdGtRZA89spXkGWxoDyd8dRt-f9wfnfuz=rACsMe3bSa_meA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/23/2014 04:41 PM, Trond Myklebust wrote:
> On Tue, Sep 23, 2014 at 3:07 AM, Jan Chaloupka <jchaloup@redhat.com> wrote:
>> mountd tcp wrappers support only NFSv2 and NFSv3, not NFSv4.
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=1116283
>>
>> This patch updates the man page
>>
>> Signed-off-by: Jan Chaloupka <jchaloup@redhat.com>
>> ---
>>  utils/mountd/mountd.man |    2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
>> index a8828ae..1aae75b 100644
>> --- a/utils/mountd/mountd.man
>> +++ b/utils/mountd/mountd.man
>> @@ -217,6 +217,8 @@ listeners using the
>>  .B tcp_wrapper
>>  library or
>>  .BR iptables (8).
>> +Tcp wrappers are only in effect with NFS version 2 and 3 mounts.
>> +They do not work with NFS version 4.
>>  .PP
>>  Note that the
>>  .B tcp_wrapper
>>
> 
> Is there any point to compiling mountd with the tcp wrappers in this
> day and age? 
>From an upstream point of view... Sure... But I don't think
we can remove them from the man pages...


> tcp wrappers isn't enforced by knfsd, so as the above
> manpage change indicates it really is only blocking NFSv2/v3 _mount_
> attempts.
> 
> If you can use NFSv4, or sniff the NFSv2/v3 traffic or even just guess
> NFSv2/v3 filehandles, then tcp wrappers can be 100% circumvented.
> 
You would be surprised on the amount of people that still use
them... 

steved.
