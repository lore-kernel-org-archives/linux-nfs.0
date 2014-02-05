Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:38824 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbaBEP44 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Feb 2014 10:56:56 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140205140906.0b3ba9fd@notabene.brown>
Date: Wed, 5 Feb 2014 10:56:39 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-Id: <1B2F95A4-8439-4274-A859-F33986D06824@oracle.com>
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org> <20140205140906.0b3ba9fd@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil!


On Feb 4, 2014, at 10:09 PM, NeilBrown <neilb@suse.de> wrote:

> On Tue, 4 Feb 2014 11:20:52 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
>> On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
>>> Also, I've been wondering if we could avoid the need to explicitly enable
>>> the gss stuff by gating it on the existence of /etc/krb5.keytab.
>>> Do you think that would be reasonable?
>> 
>> That would be great.  I hate that people have to care about these
>> support daemons, they should just be started automatically when they're
>> needed.
>> 
>> Is /etc/krb5.keytab the best indicator?
> 
> I was hoping you would tell me. :-)

rpc.gssd has to run in cases where there is no /etc/krb5.keytab.  Remember the discussion we had last year about using root’s user credential as the client’s machine credential?  We want the kernel to be able to find out whether there is a machine credential available, and one can be available even if there is no keytab.

> It occurred to me as a good test when I tried running rpc.svcgssd in a fresh
> VM and it wouldn't start.  I eventually found the error message complaining
> that it couldn't find that file.
> 
> It isn't perfect as an empty /etc/krb5.keytab will still result in failure
> and exit.  However if a sysadmin has created a keytab and is using NFS, it
> seems reasonable to be ready to provide gss services.
> 
> rpc.gssd doesn't fail in the same way, but it does complain if the file
> doesn't exist, so I suspect it is at least a good indicator.
> 
> The only thing that bothers me is that gssd is theoretically more general
> than krb5.  However as the reality seems to be that it is exactly krb5, I
> don't let that bother me too much.
> 
>> 
>> Simplest might be to start unconditionally and just not care if it
>> fails.  Or is there a problem cluttering up logs with unimportant
>> failures?
> 
> More a problem with starting things that aren't necessary, and possibly
> leaving them running.
> Every process you start adds a little to the boot time.  We only get the best
> experience if everyone contributes a little bit, no matter how little.
> Also, every running process theoretically adds the to the attack service.

rpc.gssd doesn’t expose a network listener.  What attack vector is exposed by running rpc.gssd?

Why would we insist on using a potentially insecure mechanism to provide strong security?

> So some people will definitely not want these processes to be started.

How many such people are there?  The trend I expect is that more and more people will want to use security features, and fewer will want “sec=sys,” especially if we work hard to make security features as painless as possible (as we should be doing).

It seems to me that provisionally starting rpc.gssd optimizes for a fairly uncommon case that will become less and less common going forward.  I believe we should start designing as if security is the default use case.  I would feel more comfortable if we knew more precisely what proportion of our users want to disable gssd and why.

> i.e. I agree with SteveD: 
>> I think we want to stay away (and move away) from unconditionally
>> starting anything… 

I believe we should make things simple both for us and for our customers.  Thus I agree philosophically with the Gnome strategy of removing less frequently used configuration options to reduce complexity, make things easier to configure, more reliable, and easier to troubleshoot.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



