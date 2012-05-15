Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757851Ab2EOLv1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 07:51:27 -0400
Message-ID: <4FB24326.4040909@RedHat.com>
Date: Tue, 15 May 2012 07:51:02 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.6 released.
References: <4FB159DA.2070800@RedHat.com> <20120515140646.554c378c@notabene.brown>
In-Reply-To: <20120515140646.554c378c@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/15/2012 12:06 AM, NeilBrown wrote:
> On Mon, 14 May 2012 15:15:38 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>> New Features in this release:
>>    * The addition the nfsdcld daemon
>>    * The addition of the osd_login script which is mandated by the
>>          pnfs-objects standard
>>    * The addition of -l option to rpcgssd to enforce legacy behaviour
>>
>> As well as the usual assorted bug fixes...  
>>
>> The tarball can only be found at Sourceforge.net since 
>> still unable to access ftp://ftp.kernel.org (I'm working
>> on it):
>>   http://sourceforge.net/projects/nfs
>>
>> The git tree is at:
>>    git://linux-nfs.org/nfs-utils
>>
>> The change log is also only on Sourceforge.net:
>>    http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.6/Changelog-1.2.6/download
>>
>> steved.
>>
> 
> Thanks Steve.
> 
> I noticed that the "default download" was still 1.2.5.
> 
> I wondered why and eventually found this:
> 
> https://sourceforge.net/apps/trac/sourceforge/ticket/20991
> 
> So I took the liberty of making the appropriate change, and now the default
> download is 1.2.6.
> I hope that's OK.
Definitely! I was assuming it would automatic change after a period 
of time... Thanks for taking care of it!

steved.
  
