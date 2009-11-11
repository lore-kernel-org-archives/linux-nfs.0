From: Norbert van Bolhuis <nvbolhuis-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Subject: Re: exportfs: Warning: /adir does not support NFS export.
Date: Wed, 11 Nov 2009 08:13:53 +0100
Message-ID: <4AFA6431.9010405@aimvalley.nl>
References: <4AF99861.7030103@aimvalley.nl> <20091110180747.GA15000@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr8.xs4all.nl ([194.109.24.28]:4073 "EHLO
	smtp-vbr8.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbZKKHNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 02:13:53 -0500
In-Reply-To: <20091110180747.GA15000@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, Nov 10, 2009 at 05:44:17PM +0100, Norbert van Bolhuis wrote:
>> I get the following exportfs 1.2.0 warning:
>>
>> exportfs: Warning: /adir does not support NFS export.
>>
>> Although everything works fine, I'm worried about this.
>>
>> The directoy "/adir" is the path to a ISOZFS loop mounted image.
> 
> What's ISOZFS?
> 

The ISO9660 filesystem (with rockridge extension), see mkzftree(1).

>> The ISO(Z)FS image itself resides on a UBIFS filesystem (/flashfs/isozfs_image.iso).
>> The root dir ("/"), as well as "/adir" and "/flashfs" is initramfs.
>>
>> So afaik I'm exporting a ISOFS, this is supported by nfsd (in the kernel), so
>> why is the warning there ?
>>
>> I know UBIFS doesn't support to be (nfsd) exported by the kernel,
>> but ISO(Z)FS and initramfs do, right ?
>>
>> Am I doing something illegal ?
> 
> Which distribution are you using?  Is it something that worked before,
> and stopped working, or is this the first time you've tried it?
> 
> --b.

I'm building an embedded linux system.
This is the first time I try this.

