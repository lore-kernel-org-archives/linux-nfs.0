Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 72-48-214-68.dyn.grandenetworks.net ([72.48.214.68]:59215 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726027AbeHGX2w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2018 19:28:52 -0400
Subject: Re: NFSv4 file lock reporting interface request
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Cedric Blancher <cedric.blancher@gmail.com>
Cc: Peter Scott <pjscott@jpl.nasa.gov>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
 <CALXu0UdHWGOnMYk-xGG6_GWGfdpXffc0U-+Ark0joEYvhPSh_g@mail.gmail.com>
 <20180807203419.GB18415@fieldses.org>
From: Tom Tucker <tom@opengridcomputing.com>
Message-ID: <f72df1af-1d8e-9203-0587-0e7b4a7db9aa@opengridcomputing.com>
Date: Tue, 7 Aug 2018 16:05:42 -0500
MIME-Version: 1.0
In-Reply-To: <20180807203419.GB18415@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

FWIW, I don't think dtrace does/did what NASA is asking for, but that's 
really irrelevant. The locks in NFSv4 are application specific locks, 
not generic kernel locks, so a service looking for spinlocks, mutexes, 
etc... wouldn't really be helpful I don't think.  However implementing a 
/sys/class, debugfs thingy that dumped the nfsv4 locks held is fairly 
simple, although I would think there are security implications.

Tom

On 8/7/2018 3:34 PM, J. Bruce Fields wrote:
> On Thu, Aug 02, 2018 at 08:50:20PM +0200, Cedric Blancher wrote:
>> Solaris and FreeBSD dtrace facility supports this functionality.
>> Unfortunately, Linux rejected dtrace for license issues, and instead
>> did... nothing.
> I didn't think was this sort of question tracing was designed to
> answer--it's a question about the system state at a given time (who
> holds what locks), rather than a list of events.  But I know nothing
> about dtrace.
>
> --b.
>
>> Ced
>>
>> On 10 July 2018 at 04:28, Peter Scott <pjscott@jpl.nasa.gov> wrote:
>>> Hello.  I am with the institutional hosting service at NASA's Jet Propulsion
>>> Laboratory and we have been trying to find the answer to an apparently
>>> simple question.
>>>
>>> We are running an NFSv4 server on Centos 7 and we need to get the server to
>>> tell us which files it thinks are locked by which clients.  This is because
>>> we have observed failure modes where something apparently has a lock
>>> (because attempting to lock the file again blocks) but we can't find a
>>> client that has the lock. Finding out what the server believes would be
>>> critical to troubleshooting this.
>>>
>>> We tracked down Trond Myklebust and Neil Brown and conversation suggests
>>> that this is a function that is (a) not currently available and (b)
>>> reasonable to ask for.  So this is me suggesting that an interface be
>>> provided to have knfsd output its list of locked files and clients.
>>>
>>> Regards,
>>> Peter Scott
>>> Office of the CIO
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>> -- 
>> Cedric Blancher <cedric.blancher@gmail.com>
>> [https://plus.google.com/u/0/+CedricBlancher/]
>> Institute Pasteur
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thomas Tucker
President
Open Grid Computing, Inc.
(m) 512-826-7622
(o) 512-220-3434

