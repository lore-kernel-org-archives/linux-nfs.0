Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591AbaCGPrv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 10:47:51 -0500
Message-ID: <5319EA25.5060304@RedHat.com>
Date: Fri, 07 Mar 2014 10:47:49 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Stop Background mounts hang from hanging
References: <1394204563-1166-1-git-send-email-steved@redhat.com> <D803A861-E660-4D20-BDE1-00D8C45A1228@primarydata.com>
In-Reply-To: <D803A861-E660-4D20-BDE1-00D8C45A1228@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2014 10:36 AM, Trond Myklebust wrote:
> 
> On Mar 7, 2014, at 10:02, Steve Dickson <steved@redhat.com> wrote:
> 
>> Background mounts hang forever due to the kernel not returning 
>> the time out error. The proposed fix is twofold, one in the kernel 
>> and one in the mounting code.
>>
>> The kernel patch stop the server trunking code from endlessly 
>> looping in the kernel on -ETIMEDOUT errors. Instead, the code 
>> will now return the error, allowing the mount to go into 
>> the background.
>>
>> Unfortunately, it takes over 5 mins for this timeout to 
>> happen, due the default retry strategy, which is unacceptable 
>> for background mounts. 
>>
>> So the patch I will be proposing for the mount code will be 
>> to append the "retrans=1,timeo=100" mount options to the parent
>> mount of the background mount (when they don't exist). This
>> causes the parent mount to timeout in ~25sec. 
> 
> We already have a ‘retry=‘ option for mount.nfs. According to the manpage, that should be used to specify the timeout value. Why not reuse that?
Because it didn't work... retrans and timeo had most effect on the initial times set
in  nfs_init_timeout_values()

> 
> Also, it really would be better if that timeout were under control of the mount utility itself. 
Using those options, it is under the control of mount, unless I'm misunderstanding you...
 
> How about if we allow the use of alarm() to interrupt that particular RPC call?
Why just use the mechanisms that already exist? Why invent a new one? Was my reasoning...

steved.
 
> 
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
