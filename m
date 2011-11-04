Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755839Ab1KDPzw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 11:55:52 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Nico Williams <nico@cryptonector.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>, dhowells <dhowells@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        krbdev <krbdev@mit.edu>
Subject: Re: GSSAPI Proxy initiative
Date: Fri, 4 Nov 2011 15:55:39 +0000
Message-ID: <CF863033-2ED4-4B68-B90C-54D315C67E27@netapp.com>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
 <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
 <1320332310.7734.643.camel@willson.li.ssimo.org>
 <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
 <1320337903.7734.670.camel@willson.li.ssimo.org>
 <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
 <1320352784.18396.109.camel@lade.trondhjem.org>
 <CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
 <1320355818.7734.685.camel@willson.li.ssimo.org>
 <1320356806.18396.149.camel@lade.trondhjem.org>
 <1320357606.7734.697.camel@willson.li.ssimo.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA90EE@SACMVEXC2-PRD.hq.netapp.com>
 <CAK3OfOjqCjU4O--XwVBpSBE9pwwkyBEU6OiNLN8_dM6wYe5A1w@mail.gmail.com>
In-Reply-To: <CAK3OfOjqCjU4O--XwVBpSBE9pwwkyBEU6OiNLN8_dM6wYe5A1w@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2011, at 11:13 AM, Nico Williams wrote:

> On Thu, Nov 3, 2011 at 5:16 PM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
>>> It is ok to use keyring if that's deemed the right place for session keys, but I
>>> think you already have structures where you currently store them so I don't
>>> thik you necessarily need to change that part of the kernel implementation.
>> 
>> No, but we still need to be able to do recovery of rpcsec_gss contexts once they are broken, and right now we have a major flaw due to the fact that recovery depends on a lot of small processes and data that is allowed to be swapped out at the moment when we need them the most (i.e. in a memory reclaim situation).
>> 
>> If the server reboots while our client is in the middle of writing back a file (or several files), then the client needs to recover those rpcsec_gss contexts that authenticate the processes which own any dirty pages that remain to be written out.
>> Key security is an irrelevant concern once your kernel deadlocks in an OOM state.
> 
> Ah, this problem.  Hopefully the client has enough resources to thrash
> a lot in the process but still manage to recover.  A better solution
> (see below) is possible, but will require more protocol/mechanism
> work.
> 
>>> Currently credential caches are stored in files, is there a problem with that
>>> model ? Do you need access to credential caches from the kernel when
>>> under memory pressure ?
>> 
>> Yes, there is a major problem with that model, and yes we do potentially need access to credential caches when in a recovery situation (which is a situation when we are usually under memory pressure).
> 
> Ideally we could store in each RPCSEC_GSS context (not GSS context)
> enough state on the client side to recover quickly when the server
> reboots.  

You mean not to use the user Kerberos credential to re-establish the GSS context with the server?

> How would we do this?  Suppose the server gives the client a
> "ticket", and a key much like the Kerberos ticket session key is
> agreed upon or sent by the server -- that could be stored in the
> RPCSEC_GSS context and could be used to recover it quickly for
> recovery from server reboot.  I'm eliding a lot of details here, but I
> believe this is fundamentally workable.

So re-establish the RPCSEC_GSS session lost at the server on server reboot by storing enough additional info on the client? 

-->Andy
 
> 
> A similar solution would be to store some GSS "sub-credential" in the
> RPCSEC_GSS context, but this would work for Kerberos and maybe not so
> well for other mechanisms -- and even with Kerberos, the service
> ticket might be expired when it comes time to recover.  So I prefer
> the RPCSEC_GSS-level solution I mentioned above.
> 
> If you agree with me on this then this sub-thread will be best moved
> to the NFSv4 WG, particularly if we agree on a protocol-level
> solution.
> 
> Nico
> --
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

