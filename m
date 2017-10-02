Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:55280 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdJBWDI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Oct 2017 18:03:08 -0400
Received: by mail-vk0-f52.google.com with SMTP id c19so3631119vke.11
        for <linux-nfs@vger.kernel.org>; Mon, 02 Oct 2017 15:03:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f253a98b-2f18-36ae-31a7-ce3911d798ff@wiktel.com>
References: <56BFE55D.1010509@wiktel.com> <87twjjpcl8.fsf@notabene.neil.brown.name>
 <57062C53.9080102@wiktel.com> <87wpo9lydp.fsf@notabene.neil.brown.name>
 <CAN-5tyHuuBJxwqFLkiZa5ktBk7ypCJxmZ9creeD_RGWbK4Xn3A@mail.gmail.com> <f253a98b-2f18-36ae-31a7-ce3911d798ff@wiktel.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 2 Oct 2017 18:03:06 -0400
Message-ID: <CAN-5tyGc6jdJgSNio85wWXP1jEzjGmofmxpo3XhC9G+xc_NJPQ@mail.gmail.com>
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: Richard Laager <rlaager@wiktel.com>
Cc: NeilBrown <nfbrown@novell.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 2, 2017 at 3:48 PM, Richard Laager <rlaager@wiktel.com> wrote:
> On 10/02/2017 02:45 PM, Olga Kornievskaia wrote:
>> Did turning off tcp checksum offloading take care of the problem by any chance?
>
> I don't think so, but I'm not 100% sure. I keep meaning to get back to
> working on this, but since UDP is working and it's somewhat disruptive
> to test, I haven't.
