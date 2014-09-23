Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbaIWPwV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 11:52:21 -0400
Message-ID: <5421972C.4080006@RedHat.com>
Date: Tue, 23 Sep 2014 11:52:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
References: <1411413608-16462-2-git-send-email-steved@redhat.com> <20140922152603.75005941@willson.usersys.redhat.com> <54207BCD.70101@RedHat.com> <20140922204401.GI26763@fieldses.org> <5420911D.6080506@RedHat.com> <20140922223423.GA29932@fieldses.org> <5420B78D.6040704@RedHat.com> <20140922202655.5e308e58@willson.usersys.redhat.com> <20140923015549.GB32712@fieldses.org> <54218C85.6040005@RedHat.com> <20140923151621.GB29932@fieldses.org>
In-Reply-To: <20140923151621.GB29932@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/23/2014 11:16 AM, J. Bruce Fields wrote:
> On Tue, Sep 23, 2014 at 11:06:45AM -0400, Steve Dickson wrote:
>> > 
>> > 
>> > On 09/22/2014 09:55 PM, J. Bruce Fields wrote:
>>> > > On Mon, Sep 22, 2014 at 08:26:55PM -0400, Simo Sorce wrote:
>>>> > >> No, starting before those service in itself achieves nothing.\
>>>> > >> I think what may cause the module to load maybe the fact
>>>> > >> gssproxy.service includes:
>>>> > >> Requires=proc-fs-nfsd.mount
>>> > > 
>>> > > I'd expect that to only load the nfsd module.
>>> > > 
>>> > > Hm, I think nfsd actually has a dependency on auth_rpcgss.  I wonder if
>>> > > that's correct.  Maybe that's what's doing it.
>> > It is... In another thread I clearly showed that....
> The dependency of nfsd on auth_rpcgss looks to me like an implementation
> detail.  The client module doesn't have the same dependency.  
It does... auth_rpcgss and friends are loaded during the mount
 
> We definitely shouldn't depend on it, as the dependency could get removed
> some day.
Well if that dependency gets removed (which I can't see why it ever would)
we'll deal with the then...

Remember the scope of this patch set is to enable the server to use
the gssproxy, seamlessly... As thing stand today, I think we can 
easily do that by modifying the server service file to "call" 
gssproxy when its installed... Plus since both gssproxy 
and the server have the 'Requires=proc-fs-nfsd.mount' in their
service files and Today we know that loads the needed modules
I thinking we are good go to... 

If things change down the road, lets deal with it then... 

> 
>> > So I really don't think another unit file is necessary...
> I haven't seen an alternative yet.
I'm thinking adding yet another unit file to do something that 
is already being done is just adding more complexity to an 
already confusing situation... 

So I guess my alternative is to do nothing. ;-) 

steved.
