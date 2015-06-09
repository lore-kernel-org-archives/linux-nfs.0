Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41502 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041AbbFIPhw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2015 11:37:52 -0400
Date: Tue, 9 Jun 2015 11:37:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Sean Elble <elbles@sessys.com>, Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: add no-ipv4 and no-ipv6 options
Message-ID: <20150609153751.GB32449@fieldses.org>
References: <55743EDE.7070707@gmail.com>
 <3CE6594A-508B-4BBD-9E52-CF9EDDA6274D@oracle.com>
 <557597D3.8090401@gmail.com>
 <312511264c19c5a98cbd1062531b306e@mail.sessys.com>
 <2F03891D-9240-4A8E-BEEB-7F5BBAD1B5FE@gmail.com>
 <76DB6DF0-8409-4D42-B2FD-6C7B08B148A5@gmail.com>
 <d4bfa4c82f2a8ef2dec4dce303c0c96b@mail.sessys.com>
 <20150608211210.GC27887@fieldses.org>
 <62BB9BD0-7234-41FD-A857-E2ACF7443310@sessys.com>
 <F49F031D-0666-4B2F-A9AB-955B41ADFB75@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F49F031D-0666-4B2F-A9AB-955B41ADFB75@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 09, 2015 at 11:37:38AM -0400, Chuck Lever wrote:
> 
> On Jun 8, 2015, at 9:57 PM, Sean Elble <elbles@sessys.com> wrote:
> 
> > 
> >> On Jun 8, 2015, at 5:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> On Mon, Jun 08, 2015 at 10:33:22AM -0400, Sean Elble wrote:
> >>> On 08.06.2015 10:27, Chuck Lever wrote:
> >>>>> I don’t understand the need to “turn off” an address family.
> >>>>> That’s what
> >>>>> /etc/netconfig is supposed to be for. What’s not happening here that
> >>>>> should be?
> >>>> 
> >>>> What I mean is: I’d rather not add more command line options if there
> >>>> is a way for rpc.nfsd to automatically and quietly do what is needed.
> >>>> But I don’t understand the use case here. Sean, can you explain it
> >>>> for
> >>>> bears of little brain?
> >>> 
> >>> Sure, and please correct me if any of my understanding is incorrect
> >>> (as it may well be).  In my environment, I wanted to have NFS only
> >>> listen on one interface of a multihomed host.  In using the "--host"
> >>> parameter to do so, I saw the error message regarding IPv6 thrown.
> >>> While disabling IPv6 globally in /etc/netconfig is an option (one I
> >>> understand to be "global", in that it'd affect *all* applications on
> >>> the host), it'd be nice to disable IPv6 for a single service/daemon
> >>> instead.
> >> 
> >> But doesn't something like
> >> 
> >> 	rpc.nfsd --host 10.0.0.1 --no-ipv6
> >> 
> >> seem a bit redundant?
> > 
> > In that case, perhaps it does.  But what if you were to use a hostname that resolved to both IPv4 and IPv6 addresses?
> 
> I think the common expectation is that NFSD should present an IPv6
> listener in that case.
> 
> If you give rpc.nfsd a hostname and it has no mapped IPv6 address, or
> you give rpc.nfsd an IPv4 address, then no IPv6 listener should be
> started.
> 
> >> I mean, you've already told it to listen to that one (ipv4) address.
> >> That'd argue for just disabling the warning in this case, I think.
> 
> I agree with that (either disabling it, or getting rid of the false
> negative).
> 
> >> But my understanding of IPv6 is still poor.
> > 
> > Yours and mine both.  But until it gets better, I’m very comfortable in just turning it off in places where 1) I know it’s not needed and 2) Places where exploits could linger with most of our emphasis on IPv4 still.
> 
> In the specific usage scenario you opened the thread with, you used
> a hostname with no IPv6 mapping, and you got exactly what you wanted:
> only an IPv4 listener.
> 
> Seems like the rpc.nfsd command line interface is already rich enough
> to provide what you want?

Yeah.  If somebody does need the --no-ipv4/6 stuff then we can add that
in addition, but first let's just kill the warning, it sounds to me like
that warning's just wrong.

--b.
