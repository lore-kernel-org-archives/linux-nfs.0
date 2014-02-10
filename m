Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbaBJUu5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Feb 2014 15:50:57 -0500
Message-ID: <52F93BA1.9060505@RedHat.com>
Date: Mon, 10 Feb 2014 15:50:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org> <20140205140906.0b3ba9fd@notabene.brown> <1B2F95A4-8439-4274-A859-F33986D06824@oracle.com> <20140206122751.41b2fbf9@notabene.brown> <5630CFAD-1F31-4F87-AAA7-AEB06D3EC864@oracle.com> <20140206161917.GB14575@fieldses.org>
In-Reply-To: <20140206161917.GB14575@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/06/2014 11:19 AM, J. Bruce Fields wrote:
> On Thu, Feb 06, 2014 at 11:09:58AM -0500, Chuck Lever wrote:
>>
>> On Feb 5, 2014, at 8:27 PM, NeilBrown <neilb@suse.de> wrote:
>>> I certainly agree with making things simple.  If we can make a configuration
>>> irrelevant, e.g. by gets nfsd to auto-tune the number of threads so the
>>> setting becomes pointless, then I've very happy to remove that sort of
>>> configuration.  But if a configuration option actually means something I
>>> certainly don't want to remove it.
>>>
>>> So I'm leaning towards having "systemctl {un,}mask rpc-gssd" be the
>>> configuration tool for rpc.gssd.
>>
>> I like that better than the “off-until-requested” behavior we have currently.  IMO folks who want to disable rpc.gssd will be in the increasing minority and the rest of the world will take scant notice of the extra daemon, as long as we ensure it speaks only when necessary.
> 
> I'd also prefer running the gssd's by default: one less (confusing) step
> to set up kerberos, and I'm not seeing a realistic security risk.
I'm not for starting daemon that are not needed or necessary. I
just think that is a bad design. 
 
> 
> If we can easily provide a way to turn it off for people that want a
> really stripped-down system for whatever reason, fine, let's provide
> that.
I'm thinking just the opposite... Have a way to easily (or even
automatically) way to enabled NFS security....  when needed...

Would it make it easier if we combined the gssd daemon? That goes
both ways (server and client)... That way we could just enable 
nfs security and the daemon would started regardless on what side
its on... 

steved.
