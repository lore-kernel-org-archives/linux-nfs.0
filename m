Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537Ab2CDW6g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 17:58:36 -0500
Message-ID: <4F53F39E.9050802@RedHat.com>
Date: Sun, 04 Mar 2012 17:58:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>  <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown>  <20120203142945.GA31805@us.ibm.com> <4F2E620F.5090100@panasas.com>  <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com>  <20120302192758.GA28389@us.ibm.com> <4F513429.1050209@RedHat.com>  <20120302220108.GA17119@us.ibm.com> <4F525741.2060404@RedHat.com> <1330801976.2781.19.camel@lade.trondhjem.org> <4F53ED3C.2020209@RedHat.com>
In-Reply-To: <4F53ED3C.2020209@RedHat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/04/2012 05:31 PM, Steve Dickson wrote:
>> NFSv4 is the only protocol that has a standard mount path syntax, and
>> that is because the client performs the job of interpreting the path
>> name and translating it into PUTROOTFH followed by a bunch of LOOKUPs.
>> IOW: the standard syntax there is the one imposed by the client.
>>
>> There is nothing in the NFSv2/v3 MOUNT spec that states that a path
>> needs to start with '/'. Nor is there even anything in the spec that
>> states that '/' is required to be used as the directory component
>> separator. The X/OPEN docs state that '/' is recommended for
>> portability, but do not make it a requirement. See
>> http://pubs.opengroup.org/onlinepubs/9629799/chap8.htm#tagcjh_09_02_02_03 
>>
>> IOW: I'm perfectly allowed to set up a 'mountd' server that uses '\' or
>> even something like '|' as a path component separator. This kind of
>> patch would break the client's existing ability to mount from such a
>> server.
> And where does an server like this exist? One that uses '|' as its
> path component separator?? ;-)
> 
> Just to be clear, you are ok with striping the multiple slashes, for
> all protocol versions, but its only kosher to added the leading 
> slash for v4 mounts. Correct?  
After further review... it appears this is only a v4 issue since
v3 mounts with multiple slashes appear in /proc/mounts with the
multiple slashes (unlike v4 mounts)... 

So to restate... this normalizing of the path names (aka striping 
multiple slashes or added the leading slash) only need to occur on 
(successful) v4 mounts... Although the former would not be an 
problem with v2/v3 mounts but its not needed....

steved
