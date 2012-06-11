Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40612 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab2FKQAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 12:00:08 -0400
Message-ID: <4FD615F9.2040502@panasas.com>
Date: Mon, 11 Jun 2012 18:59:53 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Benny Halevy <bhalevy@tonian.com>, Andy Adamson <androsadamson@gmail.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-2-git-send-email-andros@netapp.com> <4FCA98E7.2030006@panasas.com> <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com> <4FCE1DC1.6050100@panasas.com> <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com> <4FD5C0EA.806@tonian.com> <02293178-08CA-4CD6-A472-252860CC1FA7@netapp.com>
In-Reply-To: <02293178-08CA-4CD6-A472-252860CC1FA7@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 06:08 PM, Adamson, Andy wrote:

>> You need to wait for in-flight I/Os to either succeed, fail (e.g. time out),
>> or be aborted.  The non-successful cases are going to be reported by the
>> objects layout driver so the MDS can recover from these errors.
> 

> The object layout driver may have this requirement, but the file
> layout driver does not.


I do not see the different texts In that matter. All I see is that
for objects all the core-pnfs wording applies + the error reporting
as part of LAYOUTRETURN.

Specifically I do not see any exemption of files layout about using
layouts (segments) after a LAYOUTRETURN was sent.

And I do not agree with Benny in regard of fencing off. Objects has,
and is specifically specified, a very robust mechanism of "fencing off"
just as files has.

And I do not see anywhere, where it is permitted to the client to
send new RPCs using the same (old) layout_segment after it was returned.
Which what your patch does, because there is a race between pnfs_layout_return()
and paglist_read/write.

What is so wrong with waiting for layout_segment reference to drop
to zero? You still did not explain. What are you trying to solve
by sending a LAYOUTRETURN, before layout_segment is all released?
Please explain?

Thanks
Boaz
