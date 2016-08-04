Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933762AbcHDR30 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 13:29:26 -0400
Subject: Re: [PATCH 0/7] Assorted mount/mountd nfs-utils patches - V2
To: NeilBrown <neilb@suse.com>
References: <146976807524.20186.8871903418718212567.stgit@noble>
 <ebff995f-0de7-900f-d240-bd6dfc7d9930@RedHat.com>
 <87zios3fhd.fsf@notabene.neil.brown.name>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <ae9b5636-1cd2-b00d-c8fe-500e6faa4a13@RedHat.com>
Date: Thu, 4 Aug 2016 13:29:06 -0400
MIME-Version: 1.0
In-Reply-To: <87zios3fhd.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/04/2016 08:06 AM, NeilBrown wrote:
> On Thu, Aug 04 2016, Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>> NeilBrown (7):
>>>       nfs.man: clarify effect of 'retry' option.
>>>       mountd: remove the --exports-file option
>>>       mount: don't treat temporary name resolution failure as permanent.
>>>       mount: use a public address for IPv6 callback.
>>>       mount: fix memory leak in v4root_add_parents
>>>       mountd: allow alternate ttl to be specified for dump_to_cache.
>>>       mountd: fail nfsd.export lookup for path to unmounted exportpoint
>> The patch series committed... 
> 
> Thanks!  Have you any idea when 1.3.4 might be released.  I want
> several bits for openSUSE and I'm wondering whether to take them
> piece-meal, or to wait for a new release.
I plan doing that this weekend... 

steved.
