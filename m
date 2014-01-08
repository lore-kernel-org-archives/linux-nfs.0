Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.pictura-hosting.nl ([195.93.224.144]:38624 "EHLO
	mail.pictura-dp.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337AbaAHJKH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jan 2014 04:10:07 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 08 Jan 2014 10:09:45 +0100
From: Sander Klein <roedie@roedie.nl>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Karel Zak <kzak@redhat.com>,
        linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
In-Reply-To: <52CC6B31.4030803@RedHat.com>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
 <20131212154642.GA11521@fieldses.org> <20140106111805.GF4435@x2.net.home>
 <20140106212514.GG31764@fieldses.org>
 <0a94c641959a8084a56c688dd2242c04@roedie.nl> <52CC6B31.4030803@RedHat.com>
Message-ID: <18a0e18686ba95c7fb44d557b6b6a42d@roedie.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07.01.2014 22:01, Steve Dickson wrote:
> On 07/01/14 14:55, Sander Klein wrote:
>> Hi,
>> 
>> Thank you very much for this patch. I've added the ZFS magic and 
>> tested it on my nfs-utils-1.2.8 package and it looks like it fixes my 
>> issue.
>> 
>> Is there any chance this patch will be accepted upstream with the 
>> ZFS_SUPER_MAGIC as shown below?
> It looks reasonable to me... I committed...
> 

Great, thank you all very much for fixing this.

Regards,

Sander
