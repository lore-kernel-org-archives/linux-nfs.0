Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987Ab2CDWbw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 17:31:52 -0500
Message-ID: <4F53ED3C.2020209@RedHat.com>
Date: Sun, 04 Mar 2012 17:31:24 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>  <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown>  <20120203142945.GA31805@us.ibm.com> <4F2E620F.5090100@panasas.com>  <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com>  <20120302192758.GA28389@us.ibm.com> <4F513429.1050209@RedHat.com>  <20120302220108.GA17119@us.ibm.com> <4F525741.2060404@RedHat.com> <1330801976.2781.19.camel@lade.trondhjem.org>
In-Reply-To: <1330801976.2781.19.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/03/2012 02:12 PM, Myklebust, Trond wrote:
> On Sat, 2012-03-03 at 12:39 -0500, Steve Dickson wrote:
>>
>> On 03/02/2012 05:01 PM, Malahal Naineni wrote:
>>> Steve Dickson [SteveD@redhat.com] wrote:
>>>> So what my patch does is "normalizes" the device name early
>>>> on in main, so the correct name used used through the mount
>>>> and when its written the mtab. Plus, for better or worses, 
>>>> since the new device name will always be shorter, I just 
>>>> reuse/rewrite the memory allocated for the argv vector.. 
>>>> Meaning there is no allocation... 
>>>
>>> My problem is a bit different.
>>>
>>> "mount -t nfs4 server:export /mnt" works but umount fails.
>>>
>>> Notice that there is no '/' in the path!
>>>
>>> Normalizing or just stripping leading '/'s early won't help with the
>>> above problem and since there is already a hack to strip the
>>> __trailing__ '/' that kernel adds to /proc/mounts file, I just made the
>>> existing hack it a bit better by normalizing.
>>>
>> How about something like this... It takes on both case early on...
>>
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Sat Mar 3 12:31:23 2012 -0500
>>
>>     mount.nfs: Validate device name syntax
>>     
>>     To ensure the device name is found at unmount time strip
>>     off the multiple '/' or add a '/' if one does not exist.
>>     
>>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> NACK.
> 
> NFSv4 is the only protocol that has a standard mount path syntax, and
> that is because the client performs the job of interpreting the path
> name and translating it into PUTROOTFH followed by a bunch of LOOKUPs.
> IOW: the standard syntax there is the one imposed by the client.
> 
> There is nothing in the NFSv2/v3 MOUNT spec that states that a path
> needs to start with '/'. Nor is there even anything in the spec that
> states that '/' is required to be used as the directory component
> separator. The X/OPEN docs state that '/' is recommended for
> portability, but do not make it a requirement. See
> http://pubs.opengroup.org/onlinepubs/9629799/chap8.htm#tagcjh_09_02_02_03 
> 
> IOW: I'm perfectly allowed to set up a 'mountd' server that uses '\' or
> even something like '|' as a path component separator. This kind of
> patch would break the client's existing ability to mount from such a
> server.
And where does an server like this exist? One that uses '|' as its
path component separator?? ;-)

Just to be clear, you are ok with striping the multiple slashes, for
all protocol versions, but its only kosher to added the leading 
slash for v4 mounts. Correct?  

steved.
 
