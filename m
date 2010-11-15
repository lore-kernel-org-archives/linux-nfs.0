Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47857 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab0KOOvk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 09:51:40 -0500
Received: by bwz15 with SMTP id 15so5245052bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 06:51:39 -0800 (PST)
In-Reply-To: <4CE003A6.2000606@panasas.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
	<1289551724-18575-17-git-send-email-iisaman@netapp.com>
	<4CE003A6.2000606@panasas.com>
Date: Mon, 15 Nov 2010 09:51:39 -0500
Message-ID: <AANLkTinMiVuKJB6b6C+nZO9bMevp_jkjwVobFv7di0jq@mail.gmail.com>
Subject: Re: [PATCH 16/22] pnfs-submit: rewrite of layout state handling and cb_layoutrecall
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, NFSv4 <nfsv4@ietf.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 14, 2010 at 10:43 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>
> Using the open stateid after forgetting the layout could be a protocol bug,
> or at least it falls into undefined territories.
>
> The RFC says:
>
>   The loga_stateid field specifies a valid stateid.  If a layout is not
>   currently held by the client, the loga_stateid field represents a
>   stateid reflecting the correspondingly valid open, byte-range lock,
>   or delegation stateid.  Once a layout is held on the file by the
>   client, the loga_stateid field MUST be a stateid as returned from a
>   previous LAYOUTGET or LAYOUTRETURN operation or provided by a
>   CB_LAYOUTRECALL operation (see Section 12.5.3).
>
> So the question is does the text above refer to the client view of the state or to
> the server's view.
> In other words, with the forgetful client model, when the client unilaterally forgets
> the layout without letting the server know about it (no LAYOUTRETURN was sent),
> does it mean "a layout is not currently held by the client"?
>

I would argue that yes, this is in fact what it means.

It seems the server has two options when confronted with an
openstateid.  Either interpret this as a declaration by the client
that it has forgotten all previous layouts and behave appropriately
(wipe any layout state assigned to the file and create a new
layoutstateid), or assume this is part of parallel spew of
LAYOUTGET(openstateid) and try to use an existing layout state with
the appropriate (possibly not one) seqid.  I argue that, as the spec
stands, the second option is not really a choice, because the first
option exists.  If a client using the second option encounters a
server using the first, bad things happen.  The client will issue
multiple LAYOUTGET(openstateids), the server will, upon seeing each,
discard any previous state and return a new state with segid=1, with
the final valid state being that of whichever one was processed last.
The client will see all the OK returns, and not have any easy method
of determining which is the one that the server considers valid.

Thus I claim that, because of the forgetful model, the client must
serialize its LAYOUTGET(openstateid) calls.

> The server will see a LAYOUTGET with an open/lock/deleg stateid in this case
> while it still thinks that the client is holding a layout.
> Since this could normally happen if the client sends multiple LAYOUTGETs in
> parallel before it received any layout stateid the server should allow it
> within the VALID_SEQID_RANGE constraints (see 12.5.5.2.1.4, although it is
> not explicitly called out there), otherwise, it seems like the server is supposed
> to return NFS4ERR_OLD_STATEID.
>
> Strictly reading the spec, the client should use the most recent layout stateid
> even in the forgetful model, until it gets a LAYOUTRETURN reply with lrs_present==false
> or until it replies NFS4ERR_NOMATCHING_LAYOUT to CB_LAYOUTRECALL with
> clora_iomode==LAYOUTIOMODE4_ANY or other values where the client never dropped
> a layout (did I say recently how much I hate the forgetful model which introduces
> more corner cases rather than simplifying the protocol as it was supposed to do? ;-)
>

Strict reading again depends on whose point of view, client or server...

"Once a client has no more layouts on a file, the layout stateid is no
longer valid and MUST NOT be used.  Any attempt to use such a layout
stateid will result in NFS4ERR_BAD_STATEID."


Fred

> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
