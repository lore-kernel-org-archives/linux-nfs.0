Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:35004 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2AYO7o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 09:59:44 -0500
Received: by werb13 with SMTP id b13so3856295wer.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 06:59:43 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20120125143449.GB17873@fieldses.org>
References: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com>
	<20120125143449.GB17873@fieldses.org>
Date: Wed, 25 Jan 2012 15:59:43 +0100
Message-ID: <CAGue13on6SEq6yN485S34N0rUgj6ZuC82rxDOccDfaw4r4F=ag@mail.gmail.com>
Subject: Re: NFSv4 - Linux server, FreeBSD client
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. von Balzac" <jhm.balzac@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am adding  'insecure' option into exports to get it mounted.

Tigran.
On Wed, Jan 25, 2012 at 3:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Jan 21, 2012 at 06:04:17PM +0100, J. von Balzac wrote:
>> Hello,
>>
>> Linux (kernel 3.2) /etc/exports contains the following:
>>
>> /exp  -ro,fsid=0,async,subtree_check,all_squash,crossmnt 192.168.1.0/24
>> /exp/freebsd  -ro,no_acl,async,subtree_check,all_squash 192.168.1.0/24
>> /exp/freebsd/extra -rw,no_acl,async,subtree_check,no_root_squash 192.168.1.0/24
>> /exp/freebsd/ports  -rw,no_acl,async,subtree_check,no_root_squash 192.168.1.0/24
>
> Note no_acl is actually meaningless, and async and subtree_check are
> generally not recommended.
>
> Also, "fsid=0" tricks aren't necessary any more: if you just leave out
> that line, then v4 clients will be able to mount /exp/freebsd/* just as
> v2/v3 clients would.
>
>> I have also tested it without no_acl, and with the alternative
>> 192.168.1.0/24(options).
>>
>> The used mount command on FreeBSD and the resulting error:
>>
>> # mount_nfs -o nfsv4 192.168.1.3:/freebsd/ports /usr/ports
>> mount_nfs: /usr/ports, : Operation not permitted
>>
>> I am emailing this list and not FreeBSD, because of this next output
>> from tcpdump. Note that 192.168.1.3 is the server and 192.168.1.10 is
>> the client:
>>
>> 17:00:21.761418 IP (tos 0x0, ttl 64, id 62972, offset 0, flags [DF],
>> proto TCP (6), length 116)
>>     192.168.1.3.2049 > 192.168.1.10.1382070341: reply ok 60 getattr
>> ERROR: Operation not permitted
>
> Huh--does tcpdump even know how to parse NFSv4, or is that actually an
> NFSv3 call?
>
> The tcpdump output isn't very informative--wireshark is usually more
> helpful.
>
> What version of nfs-utils are you using?
>
> --b.
>
>>
>> The entire output of the tcpdump can be found at the following url:
>> http://sprunge.us/OVbQ
>>
>> Looking forward to resolving this.
>> Jan.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
