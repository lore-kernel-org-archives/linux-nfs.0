Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:42638 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760207Ab3LIBfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Dec 2013 20:35:21 -0500
Received: by mail-wg0-f50.google.com with SMTP id a1so2806780wgh.5
        for <linux-nfs@vger.kernel.org>; Sun, 08 Dec 2013 17:35:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131206211255.GA13148@fieldses.org>
References: <2BCCA4EF-9FCC-4320-85E1-AD500467C95D@gmail.com>
	<20131202165505.GL1960@fieldses.org>
	<529D3D3B.7060204@gmail.com>
	<20131206211255.GA13148@fieldses.org>
Date: Mon, 9 Dec 2013 09:35:20 +0800
Message-ID: <CAB6yy36zfjTNTdTKfGdX==_1RH3zrH6mwuGy0Uy3xavdm+zMdA@mail.gmail.com>
Subject: Re: [PATCH] Add missing recording of back channel attrs in nfsd4_session
From: Kinglong Mee <kinglongmee@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/12/7 J. Bruce Fields <bfields@fieldses.org>:
> On Tue, Dec 03, 2013 at 10:08:59AM +0800, Kinglong Mee wrote:
>> On 12/03/2013 12:55 AM, J. Bruce Fields wrote:
>> > On Tue, Nov 26, 2013 at 10:25:20PM +0800, Kinglong Mee wrote:
>> >> commit 5b6feee9608dce7afd2646f457c93e612526d1d8 forgot
>> >> recording the back channel attrs in nfsd4_session.
>> >>
>> >> nfsd just check the back channel attars by check_backchannel_attrs,
>> >> but do not  record it in nfsd4_session in the latest kernel.
>> >
>> > Whoops.  So the current server is returning random uninitialized data in
>> > those fields, or all zeros?
>> >
>> > It would be easy enough to write a pynfs test for this, I think.
>>
>> No, server returns right data for nfsd4_encode_create_session encoding
>> back-channel attrs from struct nfsd4_create_session, not from nfsd4_session.
>>
>> Without this patch, se_bchannel in struct nfsd4_session contains data with all zeros.
>
> Oh, I see.
>
> But actually we never use se_bchannel for anything.  Maybe the right
> thing is just to remove that field from nfsd4_session.

I'd like keep it in nfsd4_session.
Maybe nfsd will use it after a while.

thanks,
Kinglong Mee
>>
>> >>
>> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> >> ---
>> >>  fs/nfsd/nfs4state.c | 2 ++
>> >>  1 file changed, 2 insertions(+)
>> >>
>> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> >> index 105d6fa..1aed9be 100644
>> >> --- a/fs/nfsd/nfs4state.c
>> >> +++ b/fs/nfsd/nfs4state.c
>> >> @@ -999,6 +999,8 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>> >>    spin_unlock(&nn->client_lock);
>> >>    memcpy(&new->se_fchannel, &cses->fore_channel,
>> >>                    sizeof(struct nfsd4_channel_attrs));
>> >> +  memcpy(&new->se_bchannel, &cses->back_channel,
>> >> +                  sizeof(struct nfsd4_channel_attrs));
>> >>    if (cses->flags & SESSION4_BACK_CHAN) {
>> >>            struct sockaddr *sa = svc_addr(rqstp);
>> >>            /*
>> >> --
>> >> 1.8.1.4
>> >>
>> >
>>
