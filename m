Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbbFZMRa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jun 2015 08:17:30 -0400
Date: Fri, 26 Jun 2015 08:17:30 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Anders Blomdell <anders.blomdell@control.lth.se>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
In-Reply-To: <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1506260807060.13917@planck.local>
References: <55827B8D.3070103@control.lth.se> <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Jun 2015, Trond Myklebust wrote:

> On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
> <anders.blomdell@control.lth.se> wrote:
> >
> > I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
> > due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
> > https://bugzilla.redhat.com/show_bug.cgi?id=1228272.
>
>
> Why should we change the clients if the server is in clear and obvious
> violation of the spec?


What's happening here is knfsd older than 2.6.38 will return NFS4ERR_INVAL
for EXCHANGE_ID that has EXCHGID4_FLAG_BIND_PRINC_STATEID set in the
request.

Should the client's use of stateid/princ binding be optional/configureable?

Ben
