From: Jonathan Couper <jonathan-3c88B9b11vOEi8DpZVb4nw@public.gmane.org>
Subject: Mutex Hang on GC in lockd for 2.6.22-14
Date: Mon, 21 Jan 2008 18:24:52 +1300
Message-ID: <47942CA4.1060700@spiderfan.org>
References: <479427C5.8020203@spiderfan.org>
 <18324.11227.8442.938224@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4.clear.net.nz ([203.97.37.64]:37152 "EHLO
	smtp4.clear.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbYAUFj4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 00:39:56 -0500
Received: from [192.168.1.210]
 (121-72-86-24.dsl.telstraclear.net [121.72.86.24])
 by smtp4.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0JUZ0003VB1GTY20-ik10VMwhufF/PQoK6HpaanTaI6DYlTYJ@public.gmane.org> for
 linux-nfs@vger.kernel.org; Mon, 21 Jan 2008 18:24:54 +1300 (NZDT)
In-reply-to: <18324.11227.8442.938224-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Heya NFS Experts,

	I'm pretty darn sure I've found (and am currently testing a fix for) a 
mutex bug in lockd that hangs NFS server pretty reliably.  I have no 
idea how this bug has gone unnoticed for so long, since this is the
current Gutsy Gibbon kernel!

	That makes me think that maybe I'm mistaken.  But my system definitely 
hangs, and the code definitely appears to attempt to lock twice on a 
non-recursive mutex.

	All the details are:

https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/181996	

	I'd LOVE to get my name into the Linux Kernel.  Please tell me I've 
found a real bug!

	J.

Neil Brown wrote:
> On Monday January 21, jonathan-3c88B9b11vOEi8DpZVb4nw@public.gmane.org wrote:
>> Heya,
>>
>> 	I'm pretty darn sure I've found (and am currently testing a fix for) a 
>> mutex bug in lockd that hangs NFS server pretty reliably.  I have no 
>> idea how this bug has gone unnoticed for so long, since this is the 
>> current Gutsy Gibbon kernel!
>>
>> 	That makes me think that maybe I'm mistaken.  But my system definitely 
>> hangs, and the code definitely appears to attempt to lock twice on a 
>> non-recursive mutex.
>>
>> 	All the details are:
>>
>> https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/181996	
>>
>> 	I'd LOVE to get my name into the Linux Kernel.  Please tell me I've 
>> found a real bug!
>>
>> 	J.
> 
> I'll probably have a look, but please post this to
>    linux-nfs@vger.kernel.org
> 
> other people have interest in, and knowledge of, lockd.  Not just me.
> 
> Thanks,
> NeilBrown
> 

