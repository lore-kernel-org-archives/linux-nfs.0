Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:53786 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab2DKA45 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2012 20:56:57 -0400
Received: by obbtb18 with SMTP id tb18so523915obb.19
        for <linux-nfs@vger.kernel.org>; Tue, 10 Apr 2012 17:56:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120410230202.GM18465@fieldses.org>
References: <CAKnQG+dVhQ3JSXJnQihzs0FnS_aeyUKftDX7j7X6iJTjRGMzPQ@mail.gmail.com>
	<20120410215633.GL18465@fieldses.org>
	<20120410230202.GM18465@fieldses.org>
Date: Tue, 10 Apr 2012 20:56:56 -0400
Message-ID: <CAKnQG+fBw8--kfGmEvh4Fq0tzfAKq0gwi6kQHsKMQ38YmJNQ_A@mail.gmail.com>
Subject: Re: RFC: Handling GSS rotated data
From: Kevin Coffman <kwc@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 7:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Apr 10, 2012 at 05:56:33PM -0400, bfields wrote:
>> On Wed, Apr 04, 2012 at 06:28:47PM -0400, Kevin Coffman wrote:
>> > This bug points out a deficiency in the GSS code previously added to the kernel:
>> >
>> > https://bugzilla.redhat.com/show_bug.cgi?id=796992
>> >
>> > The spec (RFC 4121 section 4.2.5) says, "The receiver MUST be able to
>> > interpret all possible rotation count values, including rotation
>> > counts greater than the length of the token."  Note that an
>> > implementation is never required to send rotated data.  However it is
>> > required to be able to handle receiving rotated data.  Windows is the
>> > only implementation that I am aware of that currently sends tokens
>> > with rotated data.
>> >
>> > Attached is a patch (with way too much debugging) to handle the
>> > rotated data we have seen from Microsoft clients.  Admittedly, it does
>> > not handle all cases, which is required to be fully compliant with the
>> > spec.  I will not have the time to devote to making it fully
>> > compliant.  I submit this patch as an RFC and for someone else to
>> > complete!  Also note that I may have over-complicating things!!
>>
>> Thanks!
>>
>> But I'm not going to agree to implementing another subset of the
>> cases--we already fell into that trap once, let's not do it again.
>>
>> Even if it means we have to do something slow and stupid as the first
>> pass, I'd rather have something complete....
>
> By the way, did the cases you saw form microsoft all have a small
> rotation value?
>
> So, one approach xdr_buf_subsegment() can calculate a new xdr_buf that
> has the "correct" head, tail, and page lengths (making
> realhead/realpage/realtail unnecessary).
>
> And read_bytes_from_xdr_buf()/write_bytes_from_xdr_buf() already know
> how to do scatter/gather copies from/to an xdr_buf.
>
> And then we can use those to repeatedly shift by up to LOCAL_BUF_LEN
> bytes until we've rotated the right amount.  Assuming the typical case
> is a small (less than LOCAL_BUF_LEN) rotation value, that will only
> require one pass.  So maybe it's not too horrible.
>
> So, something like:
>
>        rrc = rrc % buf->len;
>        xdr_buf_subsegment(buf, subbuf, offset, buf->len);
>        while (shifted < rrc) {
>                this_shift = min(rrc, LOCAL_BUF_LEN);
>                shift_buf_a_little(subbuf, this_shift);
>                shifted += this_shift;
>        }
>
> void shift_buf_a_little(buf, shift)
> {
>        char head[LOCAL_BUF_LEN];
>
>        BUG_ON(shift > LOCAL_BUF_LEN);
>
>        read_bytes_from_xdr_buf(buf, 0, head, shift);
>        for (i=0; i + shift < buf->len; i += shift) {
>                char tmp[LOCAL_BUF_LEN];
>                this_len = min(shift, buf->len - i);
>                read_bytes_from_xdr_buf(buf, i+shift, tmp, this_len);
>                write_bytes_to_xdr_buf(buf, i, tmp, this_len);
>        }
>        write_bytes_to_xdr_buf(buf, buf->len - shift, head, shift);
> }
>
> ?
>
> Uh, but I'm not certain of that second function.
>
> --b.

The rotation values we've seen from Microsoft clients/servers for AES
have been 28.  Your code definitely looks simpler!

K.C.
