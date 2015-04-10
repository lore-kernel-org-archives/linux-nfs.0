Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34680 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391AbbDJSWQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 14:22:16 -0400
Received: by iedfl3 with SMTP id fl3so27117122ied.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 11:22:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5526EA56.4080606@candelatech.com>
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
	<5526EA56.4080606@candelatech.com>
Date: Fri, 10 Apr 2015 14:22:16 -0400
Message-ID: <CALs61ufjDihfRkuUM9Z1kspaKMRXfAeUpPQO8FkzmLFNg4dh6Q@mail.gmail.com>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
From: Gregory Boyce <gregory.boyce@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 9, 2015 at 5:08 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 04/09/2015 12:34 PM, Gregory Boyce wrote:
>> Folks,
>>
>> I've been encountering a problem with NFS clients attempting to mount
>> from a netapp via UDP where the netapp is responding on the wrong
>> interface.  On some of our older systems, this mount worked properly,
>> while on newer systems nfs-utils ends up failing the mount.  Mounting
>> via TCP works fine.
>>
>> It appears that there has been various related discussions over the
>> years, and a relevant Redhat bug opened back in 2006:
>>
>> http://article.gmane.org/gmane.linux.nfs/22778/match=connect+udp
>> https://bugzilla.redhat.com/show_bug.cgi?id=208244
>>
>> Is there a general recommendation for people in this sort of
>> situation?  I'm assuming the code is currently using connected UDP
>> sockets (I'm more of a sysadmin than a developer).  Is there an option
>> I'm missing to disable this?  Otherwise does anyone know of a patch to
>> change the behavior?
>
> I have some patches that allow binding an NFS client to a particular
> local IP.  You need modified mount.nfs tools as well.  These patches
> might fix your problem, but I am not certain about that.

Re-reading your e-mail, I'm not sure this will help me.   The problem
I'm having is that the server sends responses from a different IP
address than I attempted to mount.  Your description there seems to be
talking about selecting a local IP address to do the mounting with
instead.

For what it's worth, nfs-utils 1.1.2 was the version that successfully
mounts while 1.2.5 is the one I'm currently struggling with.

-- 
Greg
