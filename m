Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:53467 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcFVHaS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 03:30:18 -0400
Received: from zmail25.collab.prod.int.phx2.redhat.com (zmail25.collab.prod.int.phx2.redhat.com [10.5.83.31])
	by mx5-phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5M7EX4V041117
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 03:14:33 -0400
Date: Wed, 22 Jun 2016 03:14:32 -0400 (EDT)
From: Jayaram Radhakrishnan <jradhakr@redhat.com>
To: linux-nfs@vger.kernel.org
Message-ID: <939921093.768587.1466579672990.JavaMail.zimbra@redhat.com>
In-Reply-To: <1856161711.57783106.1464980479955.JavaMail.zimbra@redhat.com>
References: <1856161711.57783106.1464980479955.JavaMail.zimbra@redhat.com>
Subject: Re: Feature for lockd messages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Could you please provide me an update about my last update, whether this feature can include or not.

Thanks
Jayaram

----- Original Message -----
From: "Jayaram Radhakrishnan" <jradhakr@redhat.com>
To: linux-nfs@vger.kernel.org
Sent: Saturday, June 4, 2016 12:31:19 AM
Subject: Feature for lockd messages

Hello,

I would like to know if there are any chances to include the feature like, changing the error code instead of file name. As per the below error from lockd, it means its a NFS stale and throwing error code.  

~~~
<kern.warning> kernel:lockd: unexpected unlock status: 7
~~~

Behaviuor changes 

from: 
"lockd: unexpected unlock status: <unlock status code>"

to: 
"lockd: unexpected unlock status   <full path of the affected file>"

In RHEL7 kernel as well as the current upstream kernel shows a warning if the response for an unlock NFS call to the filer isn't "NLM_GRANTED".

Unfortunately the message is meaningless without the affected file. The filename is very important to do an correlation with an application or an user.

Please extend the message by printing the affected file additional to the unexpected lockd status

Is there any plans for modifying this message behavior into filename instead of throwing error code?

In general

>> NFS knows files and nothing about sockets.
>> RPC knows sockets and nothing about files. 

Awaiting for your reply

Thanks
Jayaram
