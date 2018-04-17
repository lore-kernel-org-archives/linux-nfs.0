Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36362 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752609AbeDQRju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 13:39:50 -0400
Date: Tue, 17 Apr 2018 13:39:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417173947.GJ10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <20180417150002.GF10291@parsley.fieldses.org>
 <23541B87-1142-4B59-BD57-F572FB8C1C4A@netapp.com>
 <20180417154106.GG10291@parsley.fieldses.org>
 <CAN-5tyHodwte-JUNjuqJBoyX26wFwrrmvkgc4kZrWDfN4FO_2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyHodwte-JUNjuqJBoyX26wFwrrmvkgc4kZrWDfN4FO_2Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 12:15:13PM -0400, Olga Kornievskaia wrote:
> So I see your concern that in order to allow for the destination
> server to read the file from the source server, the source server must
> allow client_id/session creation and that actually really leads to
> being able to send any other compound to the source server.

That may be, but I wasn't actually worrying about the source server, I
was worrying about the target:

> Btw, what your security thread here? If the client has control over
> the server, then what are you trying to protect? If the client
> controls the source server, then it can read whatever is stored on it
> and if it decides to provide same ability to anybody else why would
> that matter? How's any different from giving away your password to
> whomever and them accessing files as that user?

I assume the attacker knows a vunlerability in the Linux NFS client code
that processes READ (or EXCHANGE_ID or CREATE_SESSION) replies.

It sends a COPY request to an NFS server that tells it copy a file from
a "server" that the attacker controls.  The victim NFS server then tries
to read from the attacker's server, which sends replies that exploit the
vulnerability.

--b.
