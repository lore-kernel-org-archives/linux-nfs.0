Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vm-mx1.buf.com ([83.167.48.100]:47409 "EHLO vm-mx1.buf.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755474AbcARPqP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2016 10:46:15 -0500
Subject: Re: Debian kernel:
To: Harald Dunkel <harald.dunkel@aixigo.de>, linux-nfs@vger.kernel.org
References: <55C3016A.9000509@aixigo.de>
 <20150811090949.5f1a2594@dpcl082.ac.aixigo.de>
 <loom.20160107T193055-318@post.gmane.org> <5694F0E8.1060400@aixigo.de>
From: Pierre FAUQUEMBERGUE <pierref@buf.com>
Message-ID: <569D0677.8070908@buf.com>
Date: Mon, 18 Jan 2016 16:36:23 +0100
MIME-Version: 1.0
In-Reply-To: <5694F0E8.1060400@aixigo.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Harri,

thank you for your time and the tips.

so, I will do that :

1. modify /etc/default/grub with :

GRUB_CMDLINE_LINUX="nfs.nfs4_unique_id=${GRUB_DEVICE_UUID}"

2. See the result :

grub-mkconfig | less -Sr

3. rebuild grub.cfg :

sudo update-grub

4. Reboot

I will let you know, if the error keep going to appear.

thanks.


Pierre



On 01/12/2016 01:26 PM, Harald Dunkel wrote:
> Hi Pierre,
>
> On 01/07/2016 07:34 PM, PIERRRE wrote:
>> Hi,
>>
>> I have the same issue with several NFS servers. Cannot find any help.
>>
>> How did you fixed it with grub ?
> I set
> 	GRUB_CMDLINE_LINUX="nfs.nfs4_unique_id=e2177c92-1fe6-48db-918b-ddefba900379"
>
> in /etc/default/grub and rebuild the grub.cfg file.
>
> The important point is that every NFS client and every root
> partition get its own unique id. Be careful, especially if
> you clone your hosts.
>
> You can generate a new ID using uuidgen on the command line.
>
>
> Hope this helps
> Harri

