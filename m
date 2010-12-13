Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab0LMTcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 14:32:20 -0500
Message-ID: <4D0674C1.7060309@RedHat.com>
Date: Mon, 13 Dec 2010 14:32:17 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] libnsm.a: sm-notify sometimes ignores monitored hosts
References: <20101206160206.18361.26178.stgit@matisse.1015granger.net> <20101206160944.18361.28275.stgit@matisse.1015granger.net> <4D064FB4.1020209@RedHat.com> <F3286C05-D9DC-4EF7-A852-F55AC49185B9@oracle.com>
In-Reply-To: <F3286C05-D9DC-4EF7-A852-F55AC49185B9@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey...

On 12/13/2010 12:08 PM, Chuck Lever wrote:

>>>  */
>>> @@ -863,10 +879,15 @@ nsm_load_host(const char *directory, const char *filename, nsm_populate_t func)
>>> 	if (path == NULL)
>>> 		goto out_err;
>>>
>>> -	if (stat(path, &stb) == -1) {
>>> +	if (lstat(path, &stb) == -1) {
>>> 		xlog(L_ERROR, "Failed to stat %s: %m", path);
>>> 		goto out_freepath;
>>> 	}
>>> +	if (!S_ISREG(stb.st_mode)) {
>>> +		xlog(D_GENERAL, "Skipping non-regular file %s",
>>> +				path);
>> Question, why do we care non-regular files are being ignored?
> 
> We probably want to report anything unexpected in 
> the /var/lib/nfs/statd/sm{,.bak} directories.
> 
>> I understand logging the lstat() error but logging statements like
>> "ignoring this" or "not doing that" just make the debug output a 
>> bit too noisy IMHO... 
> 
> My expectation is that under normal circumstances this message 
> would never fire.  
Correct the only way they will be shown is with the "-F -d" flags... 

> statd shouldn't put anything in that directory 
> that isn't a regular file.  If there's something else in there, 
> we should report it.  Also, if statd (or something else) is broken 
> and the code thinks the object isn't a regular file, then this 
> message would point to what is wrong.
To put this in context, here are the message that come up with
the patch applied... I added a symlink to /var/lib/nfs/statd/sm/statd
to generate both messages... 

statd: Version 1.2.3 starting
statd: Flags: No-Daemon Log-STDERR TI-RPC 
sm-notify: Version 1.2.3 starting
sm-notify: Already notifying clients; Exiting!
statd: Skipping dot file ..
statd: Skipping non-regular file /var/lib/nfs/statd/sm/statd
statd: Skipping dot file .

I think we both agree the "Skipping dot file" simply not
needed... The "Skipping non-regular" message... well I have 
to say it really does not have much meaning... either.. IMHO...

But I do agree, it probably will *never* seen... 

steved.

