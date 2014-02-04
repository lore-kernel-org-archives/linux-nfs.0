Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:36951 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaBDQa3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Feb 2014 11:30:29 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140204162052.GA5295@fieldses.org>
Date: Tue, 4 Feb 2014 11:30:11 -0500
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-Id: <6599648B-7F51-48AE-9CF1-6F4858833438@oracle.com>
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 4, 2014, at 11:20 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

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

I agree 100%.

> Is /etc/krb5.keytab the best indicator?
> 
> Simplest might be to start unconditionally and just not care if it
> fails.  Or is there a problem cluttering up logs with unimportant
> failures?

IMO gssd should be started unconditionally, and we should make it quieter if needed.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



