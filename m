Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756695AbaDHPNz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 11:13:55 -0400
Date: Tue, 8 Apr 2014 11:13:54 -0400
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>, simo@redhat.com
Subject: Re: v4.0 CB_COMPOUND authentication failures
Message-ID: <20140408151354.GG3882@fieldses.org>
References: <20140408082140.340c1328@tlielax.poochiereds.net>
 <20140408123501.GA3532@fieldses.org>
 <20140408094903.33e42de2@tlielax.poochiereds.net>
 <20140408140333.GD3882@fieldses.org>
 <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com>
 <20140408144652.GE3882@fieldses.org>
 <20140408110420.62e060ef@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140408110420.62e060ef@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 08, 2014 at 11:04:20AM -0400, Jeff Layton wrote:
> On Tue, 8 Apr 2014 10:46:52 -0400
> Dr Fields James Bruce <bfields@fieldses.org> wrote:
> 
> > On Tue, Apr 08, 2014 at 10:23:37AM -0400, Trond Myklebust wrote:
> > > 
> > > On Apr 8, 2014, at 10:03, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > 
> > > > On Tue, Apr 08, 2014 at 09:49:03AM -0400, Jeff Layton wrote:
> > > >> On Tue, 8 Apr 2014 08:35:01 -0400
> > > >> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > >> 
> > > >>> On Tue, Apr 08, 2014 at 08:21:40AM -0400, Jeff Layton wrote:
> > > >>>> I've recently been hunting down some problems with delegation handling
> > > >>>> and have run across a problem with the client authenticates CB_COMPOUND
> > > >>>> requests. I could use some advice on how best to fix it.
> > > >>>> 
> > > >>>> Specifically, check_gss_callback_principal() tries to look up the
> > > >>>> callback client and then tries to compare the ticket in it against the
> > > >>>> clp->cl_hostname:
> > > >>>> 
> > > >>>>        /* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */
> > > >>>> 
> > > >>>>        if (memcmp(p, "nfs@", 4) != 0)
> > > >>>>                return 0;
> > > >>>>        p += 4;
> > > >>>>        if (strcmp(p, clp->cl_hostname) != 0)
> > > >>>>                return 0;
> > > >>>>        return 1;
> > > >>>> 
> > > >>>> The problem is that there is no guarantee that those hostnames will be
> > > >>>> the same. If, for instance, I mount "foo:/" and the SPN is
> > > >>>> "nfs/foo.bar.baz" that strcmp will return true, and the CB_COMPOUND
> > > >>>> request will get tossed out [1]. Ditto if I happen to mount a CNAME of the
> > > >>>> server.
> > > >>> 
> > > >>> It sounds like a bug to me that the mount is succeeding without the name
> > > >>> matching.
> > > >>> 
> > > >>> The security provided by krb5 is much weaker if we don't check that the
> > > >>> name provided on the commandline matches what the server authenticates
> > > >>> as.
> > > >>> 
> > > >> 
> > > >> The logic in gssd for this is pretty awful.
> > > >> 
> > > >> It will basically trust DNS if there is no '.' in the hostname that was
> > > >> used at mount time. That'll make it take the address and
> > > >> reverse-resolve it.
> > > > 
> > > > Argh, OK, I guess this is the compromise Simo made in "Avoid DNS reverse
> > > > resolution for server names (take 3)".
> > > > 
> > > >> We could add yet another band-aid and make it so that DNS is never
> > > >> trusted. I'll note that for cifs, we took that route. You have to mount
> > > >> the canonical name of the server in order to use krb5.
> > > > 
> > > > I wish we could do that, but I suppose it's too harsh to break
> > > > already-working fstabs.  Maybe we could phase it in somehow.
> > > > 
> > > >>>> Now that we try to use krb5 on the callback channel even when sec=sys
> > > >>>> is specified, this is very problematic.
> > > >>> 
> > > >>> And similarly I think the attempt to opportunistically use krb5 for
> > > >>> state management should fail and fall back on auth_sys if the server's
> > > >>> name doesn't match.
> > > >>> 
> > > 
> > > This suggestion makes no sense to me at all. How does it help to fall back to using weak security when the strong security checks fail?
> > 
> > It'd fix this particular problem.
> > 
> > But, I don't know, I'm frankly confused about our security design for
> > the NFSv4 state.
> > 
> > When we insist on krb5 (and checked the server name correctly), and
> > failed without it, then I feel like I understand what we're doing.  Once
> > we start trying it and then falling back (as I understand happens for
> > the krb5 state in the auth_sys case) I get confused.
> > 
> > > >> Like Trond pointed out, the problem is that gssd doesn't give us that
> > > >> info currently. We could change it to do that of course, but that
> > > >> basically means revving the downcall.
> > > > 
> > > > It might be easier to rev the upcall so that the kernel could ask gssd
> > > > to do strict checking?  Since it's just a bunch of name=value pairs it
> > > > shouldn't be a huge pain to revise.
> > > 
> > > So what would trigger the kernel to ask for strict checking? Do we add a mount option that says “fail if the server doesn’t authenticate itself”? That would be hard to combine with security negotiation, since it only makes sense for RPCSEC_GSS authentication.
> > 
> > I was thinking about only doing it in the state-establishment case.
> > (Since we won't know how to authenticate the callbacks in that case.)
> > 
> > But that would screw up krb5 mounts, I guess, never mind.
> > 
> > Using a fqdn implicitly requests strict checking so a mount option would
> > seem redundant.
> > 
> 
> So I guess we have two options to fix this:
> 
> 1) Change gssd to require the canonical fqdn and not rely on name
> resolution. Unfortunately, I think the MIT krb5 libs will still
> canonicalize the hostnames by default, so this might not actually fix
> anything. See:
> 
>     http://web.mit.edu/kerberos/krb5-devel/doc/admin/princ_dns.html
> 
> ...or...
> 
> 2) Loosen or somehow fix the check in check_gss_callback_principal().
> One possibility might be to do a dns_resolver upcall for the host
> portion of the SPN, and then compare the address with the server's
> address. Ugly, but since we already trust DNS implicitly I guess it's
> no less secure...

I thought Kerberos wasn't supposed to require trust in DNS.  So I feel
confused.  Cc'ing Simo in hopes he can set us all straight.

--b.
