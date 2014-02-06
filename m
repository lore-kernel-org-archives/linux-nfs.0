Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22257 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaBFQKX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 11:10:23 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140206122751.41b2fbf9@notabene.brown>
Date: Thu, 6 Feb 2014 11:09:58 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-Id: <5630CFAD-1F31-4F87-AAA7-AEB06D3EC864@oracle.com>
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org> <20140205140906.0b3ba9fd@notabene.brown> <1B2F95A4-8439-4274-A859-F33986D06824@oracle.com> <20140206122751.41b2fbf9@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 5, 2014, at 8:27 PM, NeilBrown <neilb@suse.de> wrote:

> On Wed, 5 Feb 2014 10:56:39 -0500 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Hi Neil!
>> 
>> 
>> On Feb 4, 2014, at 10:09 PM, NeilBrown <neilb@suse.de> wrote:
>> 
>>> On Tue, 4 Feb 2014 11:20:52 -0500 "J. Bruce Fields" <bfields@fieldses.org>
>>> wrote:
>>> 
>>>> On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
>>>>> Also, I've been wondering if we could avoid the need to explicitly enable
>>>>> the gss stuff by gating it on the existence of /etc/krb5.keytab.
>>>>> Do you think that would be reasonable?
>>>> 
>>>> That would be great.  I hate that people have to care about these
>>>> support daemons, they should just be started automatically when they're
>>>> needed.
>>>> 
>>>> Is /etc/krb5.keytab the best indicator?
>>> 
>>> I was hoping you would tell me. :-)
>> 
>> rpc.gssd has to run in cases where there is no /etc/krb5.keytab.  Remember the discussion we had last year about using root’s user credential as the client’s machine credential?  We want the kernel to be able to find out whether there is a machine credential available, and one can be available even if there is no keytab.
> 
> Hi Chuck,
> thanks for reminding me about that!  Yes we clearly cannot key
> off /etc/krb5.keytab for rpc.gssd.
> 
> Maybe /etc/krb5.conf?  Seems a bit lame.
> How about  /etc/gssapi_mech.conf ??  rpc.gssd seems to exit if that doesn't
> exist.  What if systemd is told not to run rpc.gssd if that file is
> missing?
> 
> I guess that otherwise we can make it on-by-default, but document that people
> can turn it off with
>     systemctl mask rpc-gssd
> 
> which is probably easier that requiring "systemctl enable nfs-secure”.

Having rpc.gssd default on when NFS is enabled is much better than the current default.  I think this would be an improvement.  The administrative burden should be on the minority of people who care enough to want it disabled.

> 
>> 
>>> It occurred to me as a good test when I tried running rpc.svcgssd in a fresh
>>> VM and it wouldn't start.  I eventually found the error message complaining
>>> that it couldn't find that file.
>>> 
>>> It isn't perfect as an empty /etc/krb5.keytab will still result in failure
>>> and exit.  However if a sysadmin has created a keytab and is using NFS, it
>>> seems reasonable to be ready to provide gss services.
>>> 
>>> rpc.gssd doesn't fail in the same way, but it does complain if the file
>>> doesn't exist, so I suspect it is at least a good indicator.
>>> 
>>> The only thing that bothers me is that gssd is theoretically more general
>>> than krb5.  However as the reality seems to be that it is exactly krb5, I
>>> don't let that bother me too much.
>>> 
>>>> 
>>>> Simplest might be to start unconditionally and just not care if it
>>>> fails.  Or is there a problem cluttering up logs with unimportant
>>>> failures?
>>> 
>>> More a problem with starting things that aren't necessary, and possibly
>>> leaving them running.
>>> Every process you start adds a little to the boot time.  We only get the best
>>> experience if everyone contributes a little bit, no matter how little.
>>> Also, every running process theoretically adds the to the attack service.
>> 
>> rpc.gssd doesn’t expose a network listener.  What attack vector is exposed by running rpc.gssd?
> 
> Not all attacks are external.  Also not all decisions relating to security
> are completely rational.  And the 'attack surface' argument may apply better
> to other services but might cause a spill-over to people not wanting to run
> anything they don't have to.

If there is any local attack vector, folks who do run rpc.gssd would be concerned about that too.  Any exposure should be addressed.

It might stand up for, say, rpcbind or rpc.statd, but I think the “attack surface” argument doesn’t stand up for any security daemon worth its salt.

> 
>> 
>> Why would we insist on using a potentially insecure mechanism to provide strong security?
>> 
>>> So some people will definitely not want these processes to be started.
>> 
>> How many such people are there?  The trend I expect is that more and more people will want to use security features, and fewer will want “sec=sys,” especially if we work hard to make security features as painless as possible (as we should be doing).
> 
> I honestly don't know.  I may be seeing spectres that aren't there.  But I've
> certainly heard a strong preference to not run unnecessary daemons more than
> once in the past.

Sure, I have too.  But I can’t think of a reason to cater to that impulse in this case.

> When NFS is only used over a tightly coupled local network (infiniband?) you
> really do want sec=sys.

True, you might not want to use integrity or privacy in such environments due to their performance impact, but Kerberos authentication can provide value to make ACLs strong or to enable secure auditing.

Besides, there is zero performance impact to running rpc.gssd with sec=sys on a big client, even if there is no KDC within miles.

> 
> 
>> 
>> It seems to me that provisionally starting rpc.gssd optimizes for a fairly uncommon case that will become less and less common going forward.  I believe we should start designing as if security is the default use case.  I would feel more comfortable if we knew more precisely what proportion of our users want to disable gssd and why.
>> 
>>> i.e. I agree with SteveD: 
>>>> I think we want to stay away (and move away) from unconditionally
>>>> starting anything… 
>> 
>> I believe we should make things simple both for us and for our customers.  Thus I agree philosophically with the Gnome strategy of removing less frequently used configuration options to reduce complexity, make things easier to configure, more reliable, and easier to troubleshoot.
> 
> I certainly agree with making things simple.  If we can make a configuration
> irrelevant, e.g. by gets nfsd to auto-tune the number of threads so the
> setting becomes pointless, then I've very happy to remove that sort of
> configuration.  But if a configuration option actually means something I
> certainly don't want to remove it.
> 
> So I'm leaning towards having "systemctl {un,}mask rpc-gssd" be the
> configuration tool for rpc.gssd.

I like that better than the “off-until-requested” behavior we have currently.  IMO folks who want to disable rpc.gssd will be in the increasing minority and the rest of the world will take scant notice of the extra daemon, as long as we ensure it speaks only when necessary.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



