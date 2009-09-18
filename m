From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 2/2] nfsd41: add RPC header size to fore channel
	negotiation
Date: Fri, 18 Sep 2009 12:47:57 -0400
Message-ID: <89c397150909180947w69b0139dx732100109e2793b0@mail.gmail.com>
References: <1252709575-3426-1-git-send-email-andros@netapp.com>
	 <1252709575-3426-2-git-send-email-andros@netapp.com>
	 <1252709575-3426-3-git-send-email-andros@netapp.com>
	 <20090914190315.GD1658@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.211.175]:55904 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbZIRQrx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Sep 2009 12:47:53 -0400
Received: by ywh5 with SMTP id 5so1422981ywh.4
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2009 09:47:57 -0700 (PDT)
In-Reply-To: <20090914190315.GD1658@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2009 at 3:03 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Fri, Sep 11, 2009 at 06:52:55PM -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Both the max request and the max response size include the RPC heade=
r with
>> credential (request only) =A0and verifier as well as the payload.
>>
>> The RPCSEC_GSS credential and verifier are the largest. Kerberos is =
the only
>> supported GSS security mechansim, so the Kerberos GSS credential and=
 verifier
>> sizes are used.
>
> Rather than trying to estimate this is might be simplest just to use
> what the server's using to allocate memory: RPCSVC_MAXPAGES. =A0No, t=
hat
> also takes into account space for the reply. =A0You could do
>
> =A0 =A0 =A0 =A0PAGE_SIZE * (1 + (RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_=
SIZE)
>
> Actually, by design the server's real limit is actually on the sum of
> the request and the reply sizes.

I think the actual limit is svc_max_payload rounded up to a multiple
of PAGE_SIZE plus PAGE_SIZE. which is a lot smaller than the sum of
the request and reply sizes. See below.

Note that svc_max_payload is what is returned in nfs4_encode_fattr for
MAXREAD and for MAXWRITE. These attributes use svc_max_payload in the
same way this patch does - the maximum data size not including rpc
headers.

I don't think the server wants is to advertise a MAXREAD/WRITE that it
can't supply because the fore channel maxrequest/maxresponse is too
small, so some additional space needs to be added to svc_max_payload
for the fore channel.

>
> What happens if we get a request such that both the request and reply
> are under our advertised limits, but the sum is too much? =A0Can we j=
ust
> declare that no client will be that weird and that we shouldn't have =
to
> worry about it?

I think the server already has this problem. In svc_init_buffer which
sets up the pages for a server thread request/response handling, it
uses sv_max_mesg / PAGE_SIZE + 1 with the comment

"extra page as we hold both request and reply. We assume one is at
most one page"

where
sv_max_mesg =3D roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE).

-->Andy

>
> --b.
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
