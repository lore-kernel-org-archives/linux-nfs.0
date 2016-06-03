Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:44543 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbcFCTBV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2016 15:01:21 -0400
Received: from zmail25.collab.prod.int.phx2.redhat.com (zmail25.collab.prod.int.phx2.redhat.com [10.5.83.31])
	by mx6-phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u53J1KoL015373
	for <linux-nfs@vger.kernel.org>; Fri, 3 Jun 2016 15:01:20 -0400
Date: Fri, 3 Jun 2016 15:01:19 -0400 (EDT)
From: Jayaram Radhakrishnan <jradhakr@redhat.com>
To: linux-nfs@vger.kernel.org
Message-ID: <1856161711.57783106.1464980479955.JavaMail.zimbra@redhat.com>
In-Reply-To: <467222610.57782401.1464980098517.JavaMail.zimbra@redhat.com>
Subject: Feature for lockd messages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
