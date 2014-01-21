Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:25704 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbaAUPkQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2014 10:40:16 -0500
Subject: Re: Too many programs calls nfsiostat.
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140121144517.5f549347@notabene.brown>
Date: Tue, 21 Jan 2014 10:40:01 -0500
Cc: varekova@redhat.com, sysstat@orange.fr,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>
References: <20130410094639.5debfc90@notabene.brown> <20140121144517.5f549347@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 20, 2014, at 10:45 PM, NeilBrown <neilb@suse.de> wrote:

> 
> (This time without the typo in Chuck's address - sorry).
> 
> Not quite a year ago I wrote:
> 
> On Wed, 10 Apr 2013 09:46:39 +1000 NeilBrown <neilb@suse.de> wrote:
> 
>> 
>> Hi all,
>> it seems that in 2010, a program called nfsiostat was added to the sysstat
>> package (http://sebastien.godard.pagesperso-orange.fr/)
>> 
>> This is unfortunate because in 2008 a program called nfsiostat was added to
>> the nfs-utils package.
>>    (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)
>> 
>> The default install locations seem to be different (/usr/bin vs /usr/sbin),
>> so packagers would not immediately notice.
>> 
>> This seems like something that should be "fixed".
>> 
>> Any suggestions what a good "fix" should look like?
>> 
>> NeilBrown
> 
> 
> No suggestions were forthcoming.
> So I have a suggestion.
> I propose we rename the "nfsiostat" in the "sysstat" package to
> "nfsio-sysstat" and the "nfsiostat" in "nfs-utils" to
> "nfs-utils-iostat".
> 
> Does anyone object?  If not I'll send off patches shortly :-)

What does the sysstat version do?  do we need two programs, or can they be merged?  Or can one be dropped?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



