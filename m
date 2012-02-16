Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62135 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab2BPSDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:03:36 -0500
Received: by eekc14 with SMTP id c14so981791eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:03:35 -0800 (PST)
Message-ID: <4F3D44F3.4000903@tonian.com>
Date: Thu, 16 Feb 2012 20:03:31 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: wireshark decoding of nfsv4.1
References: <4F3D333A.1000108@tonian.com> <20120216170019.GC6749@pad.fieldses.org>
In-Reply-To: <20120216170019.GC6749@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-02-16 19:00, J. Bruce Fields wrote:
> On Thu, Feb 16, 2012 at 06:47:54PM +0200, Benny Halevy wrote:
>> I stumbled upon a bug in wireshark decoding of NFSv4.1 open res
>> when delegation_type==OPEN_DELEGATE_NONE_EXT where od_whynone
>> seems to be ignored.
>>
>> Who owns that code nowadays?
> 
> I don't know, I see a lot of 4.1 problems, and I don't know if it's the
> wireshark version in my distro or if the problems are in upstream.  I
> haven't had time to fool with it in a few years.
> 
>> There seems to be a bug in pynfs in this area as well
>> which I'm trying to debug.
> 
> That doesn't sound familiar to me.

Apparently the bug was in my server xdr encoding code.
I just submitted a patch to fix that.

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
