Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135Ab1IZKkW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 06:40:22 -0400
Message-ID: <4E805692.1010409@RedHat.com>
Date: Mon, 26 Sep 2011 06:40:18 -0400
From: Steve Dickson <SteveD@redhat.com>
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.5 released.
References: <4E7DD35D.9080800@RedHat.com> <20110925183930.69b33573@notabene.brown>
In-Reply-To: <20110925183930.69b33573@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/25/2011 04:39 AM, NeilBrown wrote:
> On Sat, 24 Sep 2011 08:55:57 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
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
> 
> I've packaged this up for openSUSE so it should appear in openSUSE:Factory
> and probably openSUSE:Tumbleweed in a day or two.
> 
> Only oddity I noticed is that the configure script doesn't check for
> libdevmapper.h so I get a complaint when compiling instead of when
> configuring.  I don't know if that is a good thing or a bad thing, but I
> thought I would mention it.
I notice this myself... I guess a AC_CHECK_HEADER is needed when
nfsv41 is enabled... 

> 
> If my archaeology is right, this is now 4 years and 11 releases
> that you have presided over nfs-utils.  Thanks for the ongoing efforts!
You are welcome!  8-) 

steved.

