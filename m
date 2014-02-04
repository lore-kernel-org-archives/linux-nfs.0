Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753530AbaBDTAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 14:00:42 -0500
Message-ID: <52F138C9.7070804@RedHat.com>
Date: Tue, 04 Feb 2014 14:00:25 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, simo@redhat.com
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org>
In-Reply-To: <20140204162052.GA5295@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/04/2014 11:20 AM, J. Bruce Fields wrote:
> On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
>> On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com> wrote:
>>> Also how does gss-proxy come to play in all this? Maybe we 
>>> just use  gss-proxy by default and retire rpc.svcgssd.
>>
>> I haven't really be following and so am only dimly aware of gss-proxy.
>> It's a replacement for rpc.svcgssd - right?
>> So we should get it to start in the same circumstances as rpc.svcgssd?
>>
>> Is there some easy test - eg something existing in the filesystem - that we
>> could use to see if the kernel supports gss-proxy ?
> 
> There's a /proc/net/rpc/use-gss-proxy file.
hmm... I forget... who set this... gssproxy daemon? 

> 
> (But doesn't gss-proxy have users other than nfsd?)
> 
>> Also, I've been wondering if we could avoid the need to explicitly enable
>> the gss stuff by gating it on the existence of /etc/krb5.keytab.
>> Do you think that would be reasonable?
> 
> That would be great.  I hate that people have to care about these
> support daemons, they should just be started automatically when they're
> needed.
> 
> Is /etc/krb5.keytab the best indicator?
> 
> Simplest might be to start unconditionally and just not care if it
> fails.  Or is there a problem cluttering up logs with unimportant
> failures?
I think we want to stay away (and move away) from unconditionally
starting anything... Having "triggers" of when services should 
or should not be started is a better direction... Like what
Neil is doing with rpc.statd.

steved.


> 
> --b.
> 
