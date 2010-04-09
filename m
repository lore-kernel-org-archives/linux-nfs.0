From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
Date: Fri, 09 Apr 2010 12:37:40 -0400
Message-ID: <4BBF57D4.80301@oracle.com>
References: <loom.20100407T160936-119@post.gmane.org>	 <201004081739.21853.thomas.wunder@swt-bamberg.de>	 <q2z4d569c331004081158v447450e7sc962c1e3e84de0d@mail.gmail.com>	 <201004091115.27725.thomas.wunder@swt-bamberg.de> <y2o4d569c331004090750zeb56bf58udb7bbfb3277832c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Thomas Wunder <thomas.wunder@swt-bamberg.de>,
	linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:18846 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303Ab0DIQiw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Apr 2010 12:38:52 -0400
In-Reply-To: <y2o4d569c331004090750zeb56bf58udb7bbfb3277832c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/09/2010 10:50 AM, Kevin Coffman wrote:
> On Fri, Apr 9, 2010 at 5:15 AM, Thomas Wunder
> <thomas.wunder@swt-bamberg.de>  wrote:
>> On Thursday 08 April 2010 20:58:49 you wrote:
>>> Sorry, I missed that, or forgot.  And you still get "mount : only root
>>> can mount ..." if you do "mount /mnt/net" as tomkrb ??  If so, that
>>> seems like a bug.
>>
>> No, with that entry each user is able to invoke mount. The problem is that
>> mount is carried out with uid=0 then.
>>
>>> Yes, because under sudo, you are running as root.
>> obviously...
>>
>> I'm wondering if there's a chance to run mount with a non-root uid at all. On
>> the other hand is that really needed? I mean I just want it to pass the
>> calling user's uid to the rpc.gssd...
>>
>> By the way the rpcsec_gss_krb5 is loaded.
>>
>>>   You said you had this working for the case where root did the mount
>>> using a keytab though, correct?  It can also be caused by a mismatch
>>> of sec flavors.  (i.e., is the server exporting with krb5p?)
>> Yes, it worked fine when i used a keytab-file with the key for the client-
>> machine-principal in it. When i issued mount everything worked fine. The
>> problem with this kind of setup is just that this would simply be some kind of
>> host-based authentication and I can't trust the people which will use the
>> clients as much to use a keytab file. They could simply boot from a LiveCD,
>> memstick etc. and steal that keytab file...
>> I've double checked that krb5p is specified in the server's /etc/exports as
>> well as in the client's /etc/fstab (i've also tried it with "krb5" on both
>> sides but that didn't make any difference) .
>>
>> Does it matter whether those two flags match before the security context is
>> completely established at all?
>
> I tried a user mount yesterday and it worked fine, but I had a keytab
> on the machine.  Looking closer today, I see two upcalls coming up for
> the user-mount case.  The first has uid 0, as you say.  The second was
> with my uid.  Removing my keytab causes the mount to fail as you are
> seeing.  Sorry to take so long to figure that out.
>
> I don't think this has always been the case.  Something might have
> changed with the new kernel mount code?
>
> Copying Chuck to see if he knows more...

I don't know anything about these upcalls, sorry.

-- 
chuck[dot]lever[at]oracle[dot]com
