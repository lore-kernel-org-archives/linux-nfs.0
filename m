Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:37526 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbbDJSpi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 14:45:38 -0400
Message-ID: <55281A51.3030408@candelatech.com>
Date: Fri, 10 Apr 2015 11:45:37 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Gregory Boyce <gregory.boyce@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com> <5526EA56.4080606@candelatech.com> <CALs61ufjDihfRkuUM9Z1kspaKMRXfAeUpPQO8FkzmLFNg4dh6Q@mail.gmail.com>
In-Reply-To: <CALs61ufjDihfRkuUM9Z1kspaKMRXfAeUpPQO8FkzmLFNg4dh6Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/10/2015 11:22 AM, Gregory Boyce wrote:
> On Thu, Apr 9, 2015 at 5:08 PM, Ben Greear <greearb@candelatech.com> wrote:
>> On 04/09/2015 12:34 PM, Gregory Boyce wrote:
>>> Folks,
>>>
>>> I've been encountering a problem with NFS clients attempting to mount
>>> from a netapp via UDP where the netapp is responding on the wrong
>>> interface.  On some of our older systems, this mount worked properly,
>>> while on newer systems nfs-utils ends up failing the mount.  Mounting
>>> via TCP works fine.
>>>
>>> It appears that there has been various related discussions over the
>>> years, and a relevant Redhat bug opened back in 2006:
>>>
>>> http://article.gmane.org/gmane.linux.nfs/22778/match=connect+udp
>>> https://bugzilla.redhat.com/show_bug.cgi?id=208244
>>>
>>> Is there a general recommendation for people in this sort of
>>> situation?  I'm assuming the code is currently using connected UDP
>>> sockets (I'm more of a sysadmin than a developer).  Is there an option
>>> I'm missing to disable this?  Otherwise does anyone know of a patch to
>>> change the behavior?
>>
>> I have some patches that allow binding an NFS client to a particular
>> local IP.  You need modified mount.nfs tools as well.  These patches
>> might fix your problem, but I am not certain about that.
> 
> Re-reading your e-mail, I'm not sure this will help me.   The problem
> I'm having is that the server sends responses from a different IP
> address than I attempted to mount.  Your description there seems to be
> talking about selecting a local IP address to do the mounting with
> instead.
> 
> For what it's worth, nfs-utils 1.1.2 was the version that successfully
> mounts while 1.2.5 is the one I'm currently struggling with.


Ok, I thought maybe you were using two interfaces on your client and the
request was coming down the wrong interface due to the client selecting
the wrong source address when sending the original request.

But if it is purely server-side issue, then yes, my patches are unlikely
to help anything.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

