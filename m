Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31334 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932554Ab1KDQa0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 12:30:26 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Nico Williams <nico@cryptonector.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>, dhowells <dhowells@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        krbdev <krbdev@mit.edu>
Subject: Re: GSSAPI Proxy initiative
Date: Fri, 4 Nov 2011 16:30:13 +0000
Message-ID: <4110733A-4C73-481B-96D5-D6C3BDBB16CD@netapp.com>
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
 <CF863033-2ED4-4B68-B90C-54D315C67E27@netapp.com>
 <CAK3OfOgdgPEe85z152Hi06E8GwpZZJ9ch-Vq1GneMCW6nBZ6pw@mail.gmail.com>
In-Reply-To: <CAK3OfOgdgPEe85z152Hi06E8GwpZZJ9ch-Vq1GneMCW6nBZ6pw@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2011, at 12:20 PM, Nico Williams wrote:

> On Fri, Nov 4, 2011 at 10:55 AM, Adamson, Andy
> <William.Adamson@netapp.com> wrote:
>> On Nov 4, 2011, at 11:13 AM, Nico Williams wrote:
>>> Ideally we could store in each RPCSEC_GSS context (not GSS context)
>>> enough state on the client side to recover quickly when the server
>>> reboots.
>> 
>> You mean not to use the user Kerberos credential to re-establish the GSS context with the server?
> 
> Kerberos has tickets.  Other GSS mechanisms don't.  The GSS-API
> completely abstracts this, so there's no way to extract a service
> ticket and store it alongside the context (RPCSEC_GSS, in this case)
> where you might need it in the future.  Storing all of a GSS-API
> credential (think of a whole ccache) in kernel memory is not an option
> either (ccaches have unbounded size).

Well, don't all GSS mechanisms have credentials? We use the UID to map between the RPCSEC_GSS context and the credential, so we don't need to store the credential along side of the context.

That said, I agree that a light-weight method of re-establishing a context is very appealing.

-->Andy

> 
> Moreover, if we do this in a light-weight enough fashion we might be
> able to handle all of the recovery path in kernel-mode, with no
> dependence on upcalls.  But if we didn't by somehow extracting the
> service ticket and storing it in the RPCSEC_GSS context we'd probably
> still need to upcall to make use of it.
> 
>>> How would we do this?  Suppose the server gives the client a
>>> "ticket", and a key much like the Kerberos ticket session key is
>>> agreed upon or sent by the server -- that could be stored in the
>>> RPCSEC_GSS context and could be used to recover it quickly for
>>> recovery from server reboot.  I'm eliding a lot of details here, but I
>>> believe this is fundamentally workable.
>> 
>> So re-establish the RPCSEC_GSS session lost at the server on server reboot by storing enough additional info on the client?
> 
> Yes.  And not just server reboot.  The server is free to lose
> RPCSEC_GSS contexts any time it wants to.
> 
> Basically, we need a fast re-authentication facility that is easy to
> code entirely in kernel-mode.  Thinking of it this way I would not
> reuse any Kerberos tech for this.  The server would return a ticket in
> RPCSEC_GSS context establishment, but the ticket would consist of
> {secret key index, encrypted octet string} and the server and client
> would both compute a "session key" (for proving ticket possession)
> with GSS_Pseudo_random() (this way we can make this work even when the
> GSS mech only does MICs and not wrap tokens).  To re-authenticate the
> client would send the ticket and an authenticator just like in
> Kerberos, but simpler.
> 
> Nico
> --
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

