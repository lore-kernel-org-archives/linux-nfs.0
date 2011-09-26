Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122Ab1IZK2q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 06:28:46 -0400
Message-ID: <4E8053DA.6060504@RedHat.com>
Date: Mon, 26 Sep 2011 06:28:42 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.5 released.
References: <4E7DD35D.9080800@RedHat.com> <4E7EB7CE.5040502@tonian.com>
In-Reply-To: <4E7EB7CE.5040502@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/25/2011 01:10 AM, Benny Halevy wrote:
> Steve, I updated git://linux-nfs.org/~bhalevy/pnfs-nfs-utils
> rebased onto 1.2.5.
> 
> It looks like you forgot to add/publish the tag nfs-utils-1-2-5.
It appears you correct.. Sorry about that...

The nfs-utils-1-2-5 tag has been pushed.

steved.

> 
> Benny
> 
> On 2011-09-24 15:55, Steve Dickson wrote:
>> New Features in this release:
>>
>>    * With the addition of the blkmapd daemon, the client 
>>      now supports every pNFS layout type. 
>>
>>    * The usual assorted bug fixes. 
>>
>> The tarball can only be found at Sourceforge.net since 
>> master.kernel.org is still down:
>>
>>   http://sourceforge.net/projects/nfs
>>
>> [ Maybe we should start thinking about putting the rpms on linux-nfs.org?? ]
>>
>> The git tree is at:
>>    git://linux-nfs.org/nfs-utils
>>
>> The change log is also only on Sourceforge.net:
>>
>> http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.5/Changelog-1.2.5/download
>>
>> steved.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
