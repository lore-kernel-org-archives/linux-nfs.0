Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44588 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025AbaBKQ5B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 11:57:01 -0500
Date: Tue, 11 Feb 2014 11:56:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140211165658.GC19599@fieldses.org>
References: <20140204162052.GA5295@fieldses.org>
 <20140205140906.0b3ba9fd@notabene.brown>
 <1B2F95A4-8439-4274-A859-F33986D06824@oracle.com>
 <20140206122751.41b2fbf9@notabene.brown>
 <5630CFAD-1F31-4F87-AAA7-AEB06D3EC864@oracle.com>
 <20140206161917.GB14575@fieldses.org>
 <52F93BA1.9060505@RedHat.com>
 <20140211155052.464aac7c@notabene.brown>
 <20140211163712.GB19599@fieldses.org>
 <52FA543C.1080004@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <52FA543C.1080004@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 11, 2014 at 11:47:56AM -0500, Steve Dickson wrote:
> 
> 
> On 02/11/2014 11:37 AM, J. Bruce Fields wrote:
> > On Tue, Feb 11, 2014 at 03:50:52PM +1100, NeilBrown wrote:
> >> On Mon, 10 Feb 2014 15:50:41 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> >>
> >>> On 02/06/2014 11:19 AM, J. Bruce Fields wrote:
> >>>> On Thu, Feb 06, 2014 at 11:09:58AM -0500, Chuck Lever wrote:
> >>>>>
> >>>>> On Feb 5, 2014, at 8:27 PM, NeilBrown <neilb@suse.de> wrote:
> >>>>>> I certainly agree with making things simple.  If we can make a configuration
> >>>>>> irrelevant, e.g. by gets nfsd to auto-tune the number of threads so the
> >>>>>> setting becomes pointless, then I've very happy to remove that sort of
> >>>>>> configuration.  But if a configuration option actually means something I
> >>>>>> certainly don't want to remove it.
> >>>>>>
> >>>>>> So I'm leaning towards having "systemctl {un,}mask rpc-gssd" be the
> >>>>>> configuration tool for rpc.gssd.
> >>>>>
> >>>>> I like that better than the “off-until-requested” behavior we have currently.  IMO folks who want to disable rpc.gssd will be in the increasing minority and the rest of the world will take scant notice of the extra daemon, as long as we ensure it speaks only when necessary.
> >>>>
> >>>> I'd also prefer running the gssd's by default: one less (confusing) step
> >>>> to set up kerberos, and I'm not seeing a realistic security risk.
> >>> I'm not for starting daemon that are not needed or necessary. I
> >>> just think that is a bad design. 
> >>>  
> >>>>
> >>>> If we can easily provide a way to turn it off for people that want a
> >>>> really stripped-down system for whatever reason, fine, let's provide
> >>>> that.
> >>> I'm thinking just the opposite... Have a way to easily (or even
> >>> automatically) way to enabled NFS security....  when needed...
> >>>
> >>> Would it make it easier if we combined the gssd daemon? That goes
> >>> both ways (server and client)... That way we could just enable 
> >>> nfs security and the daemon would started regardless on what side
> >>> its on... 
> >>>
> >>> steved.
> >>
> >> By "combine" do you mean "rewrite the code so there is only one process" or
> >> "have a systemd unit which starts both"?  The former seems like a lot of
> >> pointless work and the later contradicts your stated preference for not
> >> starting daemons that are not needed.
> > 
> > Note the client needs svcgssd or gss-proxy too, if you want it to be
> > able to get delegations over NFSv4.0.  (It doesn't matter for versions
> > 2, 3, or >=4.1).
> Even when kerberos is not configured? 

No.  So an attempt to summarize:
	- not using kerberos?  You don't need any daemons.
	- using kerberos, NFS version 2, 3, or >=4.1?  You need rpc.gssd
	  on the client, and rpc.svcgssd (or gss-proxy) on the server.
	- using kerberos, NFS version 4.0, care about delegations
	  working?  You need both rpc.gssd and rpc.svcgssd (or
	  gss-proxy) on both server and client.

> > I still pretty vague on exactly what problems we solve by turning off
> > these daemons by default.
> To keep things simple....

"Always start" is simpler logic than, say, "start if /etc/krb5.conf is
available".

--b.
