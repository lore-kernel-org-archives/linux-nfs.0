From: Ben DJ <bendj095124367913213465@gmail.com>
Subject: Re: are multiple FSIDs supported?
Date: Fri, 23 Oct 2009 12:09:25 -0700
Message-ID: <babafd2f0910231209w3c9ea401pc2e38b352e5f416f@mail.gmail.com>
References: <babafd2f0910231132n464da0crc2a5cc0427af9a40@mail.gmail.com>
	<20091023190053.GB32155@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:55654 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbZJWTJk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2009 15:09:40 -0400
Received: by pwj9 with SMTP id 9so320805pwj.21
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2009 12:09:45 -0700 (PDT)
In-Reply-To: <20091023190053.GB32155@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Fri, Oct 23, 2009 at 12:00 PM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
>> My goal would be to export, for example
>>
>> =A0/nfs1 & it's subdirs ONLY to LAN box1
>> =A0/nfs2 & it's subdirs ONLY to LAN box2
>> =A0etc
>
> Multiple export namespaces aren't currently supported.
>
> I'd like to some day, though I'd prefer to vary the namespace based o=
n
> server ip address instead of by client ip address.
>
> But for now I'd think just something like:
>
> =A0 =A0 =A0 =A0/nfs =A0 =A0*(ro,fsid=3D0,...)
> =A0 =A0 =A0 =A0/nfs/1 =A0box1(rw,nohide,crossmnt)
> =A0 =A0 =A0 =A0/nfs/2 =A0box2(rw,nohide,crossmnt)
>
> should server your purposes. =A0box1 will still be able to see that a
> directory named /nfs/2 exists,

There are a few situations where I'm going to have to figure out a way
around this.  I.e., where I don't want boxes to even "be able to see"
other boxes' dirs.

> but it shouldn't be able to descend into
> it. =A0(And vice-versa for box2 and /nfs/1.)

Thanks for the suggestion and explanation.  I'd seen the crossmnt
option, but didn't understand how it was really different than nohide.

BenDJ
