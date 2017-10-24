Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42612 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbdJXNfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Oct 2017 09:35:14 -0400
Date: Tue, 24 Oct 2017 09:35:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 00/10] NFSD support for asynchronous COPY
Message-ID: <20171024133512.GA30872@parsley.fieldses.org>
References: <20171013205412.65532-1-kolga@netapp.com>
 <20171013212626.GB28854@parsley.fieldses.org>
 <CAN-5tyETeVgOWKeFSBxQBJi6wwXTcgQqaxxLn0BFXCTCv09h0g@mail.gmail.com>
 <b4f0f30e-c19e-1b2f-7379-d859b4b5ff49@Netapp.com>
 <20171016164935.GD19720@parsley.fieldses.org>
 <CAN-5tyG74LpQytszp0k_+gCZN-1D_fCUeS=KHD9ggcCOrKfCxQ@mail.gmail.com>
 <CAN-5tyEtGgk=_iR60Zr6objNA--9FNQjKYkqRTDydRcAwsxOQw@mail.gmail.com>
 <CAN-5tyGsO-i3nNwwUArFB2D+howw+CJonGGjjCyW_yigGes0xA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGsO-i3nNwwUArFB2D+howw+CJonGGjjCyW_yigGes0xA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 23, 2017 at 06:39:54PM -0400, Olga Kornievskaia wrote:
> Do you have any more comments on the current async patches or should I
> post a new version? I plan to do the original OFFLOAD_STATUS looping
> and I'm planning to change server to not send the EINVAL error to the
> client and instead send a partial copy and 0 when reading past the end
> of the file.

That sounds good, I'm afraid I don't have any pending comments, so
resending is fine.

--b.
