Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49541 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab1LLQmz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 11:42:55 -0500
Received: by wgbdr13 with SMTP id dr13so11743175wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 08:42:54 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20111212160439.GE18185@fieldses.org>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1323621708-25138-2-git-send-email-tigran.mkrtchyan@desy.de>
	<4EE61BE4.9060808@tonian.com>
	<20111212160439.GE18185@fieldses.org>
Date: Mon, 12 Dec 2011 17:42:54 +0100
Message-ID: <CAGue13qupicO5oP0zVKWh92UGV1txB9LXsw7=JC07Jdga+4XZQ@mail.gmail.com>
Subject: Re: [PATH v3 1/5] nfsd41: handle current stateid in open and close
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Benny Halevy <bhalevy@tonian.com>,
        Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 5:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Dec 12, 2011 at 05:21:08PM +0200, Benny Halevy wrote:
>> On 2011-12-11 18:41, Tigran Mkrtchyan wrote:
>> > @@ -1411,9 +1441,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
>> >     },
>> >     [OP_CLOSE] = {
>> >             .op_func = (nfsd4op_func)nfsd4_close,
>> > -           .op_flags = OP_MODIFIES_SOMETHING,
>> > +           .op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,
>>
>> Looks like this also requires PROVIDES_CURRENT_STATEID
>> (or just ditch the flag so there can't be disagreement between the two :)
>
> Please, yes, let's just eliminate the redundant flags.

Fine with me.

Tigran.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
