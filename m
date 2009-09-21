From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 2/2] nfsd41: add RPC header size to fore channel
	negotiation
Date: Mon, 21 Sep 2009 08:29:30 -0400
Message-ID: <89c397150909210529q5b119d9dmff958dfe2d859635@mail.gmail.com>
References: <1252709575-3426-1-git-send-email-andros@netapp.com>
	 <1252709575-3426-2-git-send-email-andros@netapp.com>
	 <1252709575-3426-3-git-send-email-andros@netapp.com>
	 <20090914190315.GD1658@fieldses.org>
	 <89c397150909180947w69b0139dx732100109e2793b0@mail.gmail.com>
	 <20090918211253.GE26222@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f173.google.com ([209.85.210.173]:59030 "EHLO
	mail-yx0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946AbZIUMuK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2009 08:50:10 -0400
Received: by yxe3 with SMTP id 3so3292999yxe.4
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2009 05:50:12 -0700 (PDT)
In-Reply-To: <20090918211253.GE26222@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 18, 2009 at 5:12 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Fri, Sep 18, 2009 at 12:47:57PM -0400, William A. (Andy) Adamson w=
rote:
>> On Mon, Sep 14, 2009 at 3:03 PM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
>> > On Fri, Sep 11, 2009 at 06:52:55PM -0400, andros@netapp.com wrote:
>> >> From: Andy Adamson <andros@netapp.com>
>> >>
>> >> Both the max request and the max response size include the RPC he=
ader with
>> >> credential (request only) =A0and verifier as well as the payload.
>> >>
>> >> The RPCSEC_GSS credential and verifier are the largest. Kerberos =
is the only
>> >> supported GSS security mechansim, so the Kerberos GSS credential =
and verifier
>> >> sizes are used.
>> >
>> > Rather than trying to estimate this is might be simplest just to u=
se
>> > what the server's using to allocate memory: RPCSVC_MAXPAGES. =A0No=
, that
>> > also takes into account space for the reply. =A0You could do
>> >
>> > =A0 =A0 =A0 =A0PAGE_SIZE * (1 + (RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PA=
GE_SIZE)
>> >
>> > Actually, by design the server's real limit is actually on the sum=
 of
>> > the request and the reply sizes.
>>
>> I think the actual limit is svc_max_payload rounded up to a multiple
>> of PAGE_SIZE plus PAGE_SIZE. which is a lot smaller than the sum of
>> the request and reply sizes. See below.
>
> Right. =A0 I think you're agreeing with me?

yes!

>
>> Note that svc_max_payload is what is returned in nfs4_encode_fattr f=
or
>> MAXREAD and for MAXWRITE. These attributes use svc_max_payload in th=
e
>> same way this patch does - the maximum data size not including rpc
>> headers.
>>
>> I don't think the server wants is to advertise a MAXREAD/WRITE that =
it
>> can't supply because the fore channel maxrequest/maxresponse is too
>> small, so some additional space needs to be added to svc_max_payload
>> for the fore channel.
>
> Yes.

=46or the additional space, shall we use what this patch calculates or
some other metric?

>
>> > What happens if we get a request such that both the request and re=
ply
>> > are under our advertised limits, but the sum is too much? =A0Can w=
e just
>> > declare that no client will be that weird and that we shouldn't ha=
ve to
>> > worry about it?
>>
>> I think the server already has this problem. In svc_init_buffer whic=
h
>> sets up the pages for a server thread request/response handling, it
>> uses sv_max_mesg / PAGE_SIZE + 1 with the comment
>>
>> "extra page as we hold both request and reply. We assume one is at
>> most one page"
>>
>> where
>> sv_max_mesg =3D roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE)=
=2E
>
> Right. =A0The difference is that now it looks to me like we're actual=
ly
> going to start promising that we support the large request + large
> response case, when actually we don't.

OK - I see your point. With MAXREAD or MAXWRITE we only promise either
a large request or a large response per compound, not a large request
and a large response in a single compound, e.g. a read and a write in
the same compound.

>
> I guess the problem's unlikely to arise, so maybe it's not worth fixi=
ng.
> But it's annoying to have yet another undocumented restriction on the
> compounds we'll accept.

I wonder what other servers are doing.

-->Andy

>
> --b.
>
