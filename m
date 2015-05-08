Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbbEHMZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 08:25:29 -0400
Date: Fri, 8 May 2015 08:25:19 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
cc: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
In-Reply-To: <110354172.1516782.1431074928783.JavaMail.zimbra@desy.de>
Message-ID: <alpine.OSX.2.19.9992.1505080824560.656@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com> <110354172.1516782.1431074928783.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:

> Hi Olga,
>
> I believe we see the same infinite loop without delegation with RHEL6/7
> kernels, but without delegation being involved. Currently, on the server
> side, if client looping is detected, we return RESOURCE. This breaks the
> loop and application gets an IO error.
>
> Your fix is only covers the delegation case isn't it?
>
> Tigran.

Tigran, do you have a BZ or can you tell me how to reproduce this?

Ben
