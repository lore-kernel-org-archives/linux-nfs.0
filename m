From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: 2.6.24: RPC: bad TCP reclen 0x00020090 (large)
Date: Fri, 14 Mar 2008 12:28:19 -0500
Message-ID: <C4001FE3.3BDB9%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
To: <mjt@tls.msk.ru>, <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:13455 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676AbYCNR21 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Mar 2008 13:28:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Michael:

>>>>> On Wed, 13 Feb 2008 17:02:53 +0300 Michael Tokarev <mjt@tls.msk.ru> wrote:
>>>>> 
>>>>>> Hello!
>>>>>> 
>>>>>> After upgrading to 2.6.24 (from .23), we're seeing ALOT
>>>>>> of messages like in $subj in dmesg:
>>>>>> 
>>>>>> Feb 13 13:21:39 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
>>>>>> Feb 13 13:21:46 paltus kernel: printk: 3586 messages suppressed.
>>>>>> Feb 13 13:21:46 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
>>>>>> Feb 13 13:21:49 paltus kernel: printk: 371 messages suppressed.
>>>>>> Feb 13 13:21:49 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
>>>>>> Feb 13 13:21:55 paltus kernel: printk: 2979 messages suppressed.
>>>>>> ...
>>>>>> 

Are you seeing this with the latest bits?  I just want to make sure that
this particular close path issue is fixed.

Thanks,
Tom


