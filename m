Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.wiktel.com ([69.89.207.151]:45078 "EHLO smtp1.wiktel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751055AbdJBTyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Oct 2017 15:54:47 -0400
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: Olga Kornievskaia <aglo@umich.edu>, NeilBrown <nfbrown@novell.com>
References: <56BFE55D.1010509@wiktel.com>
 <87twjjpcl8.fsf@notabene.neil.brown.name> <57062C53.9080102@wiktel.com>
 <87wpo9lydp.fsf@notabene.neil.brown.name>
 <CAN-5tyHuuBJxwqFLkiZa5ktBk7ypCJxmZ9creeD_RGWbK4Xn3A@mail.gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
From: Richard Laager <rlaager@wiktel.com>
Message-ID: <f253a98b-2f18-36ae-31a7-ce3911d798ff@wiktel.com>
Date: Mon, 2 Oct 2017 14:48:27 -0500
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHuuBJxwqFLkiZa5ktBk7ypCJxmZ9creeD_RGWbK4Xn3A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/02/2017 02:45 PM, Olga Kornievskaia wrote:
> Did turning off tcp checksum offloading take care of the problem by any chance?

I don't think so, but I'm not 100% sure. I keep meaning to get back to
working on this, but since UDP is working and it's somewhat disruptive
to test, I haven't.

-- 
Richard
