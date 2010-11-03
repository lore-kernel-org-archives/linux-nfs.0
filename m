From: "fibreraid@gmail.com" <fibreraid@gmail.com>
Subject: Re: Streaming perf problem on 10g
Date: Wed, 3 Nov 2010 11:47:37 -0700
Message-ID: <AANLkTimxDBwjOZ+jmSap+-qDsGZpSGOewYtbfUk60D=G@mail.gmail.com>
References: <766909857.700951.1288807081999.JavaMail.root@mb2>
	<4CD1AAE2.3020003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Joe Landman <joe.landman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65014 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab0KCSrj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 14:47:39 -0400
Received: by wwe15 with SMTP id 15so999840wwe.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 Nov 2010 11:47:38 -0700 (PDT)
In-Reply-To: <4CD1AAE2.3020003@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Shehjar,

Can you provide the exact dd command you are running both locally and
for the NFS mount?

-Tommy

On Wed, Nov 3, 2010 at 11:33 AM, Joe Landman <joe.landman@gmail.com> wr=
ote:
> On 11/03/2010 01:58 PM, Shehjar Tikoo wrote:
>>
>> Hi All,
>>
>> I am running into a performance problem with 2.6.32-23 Ubuntu lucid =
on
>> both client and server.
>>
>> The disk is an SSD performing at 1.4 - 1.6Gbps for a dd of a 6gb fil=
e in
>> 64k blocks.
>>
>
> If the size of this file is comparable to or smaller than the client =
or
> server ram, this number is meaningless.
>
>> The network is performing fine with many Gbps of iperf throughput.
>>
>
> GbE gets you 1 Gbps. =A010GbE may get you from 3-10 Gbps, depending u=
pon many
> things. =A0What are =A0your numbers?
>
>> Yet, the dd write performance over the nfs mount point ranges from 9=
6-105
>> Mbps for a 6gb file in 64k blocks.
>>
>
> Sounds like you are writing over the gigabit, and not the 10GbE inter=
face.
>
>> I've tried changing the tcp_slot_table_entries and the wsize but the=
re is
>> negligible gain from these.
>>
>> Does it sound like a client side inefficiency?
>>
>
> Nope.
>
> --
> Joseph Landman, Ph.D
> Founder and CEO
> Scalable Informatics Inc.
> email: landman-nyOC7EYE20mM0MU9lROt9DlRY1/6cnIP@public.gmane.org
> web : http://scalableinformatics.com
> phone: +1 734 786 8423 x121
> fax : +1 866 888 3112
> cell : +1 734 612 4615
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
