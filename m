Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-sn1nam01on0065.outbound.protection.outlook.com ([104.47.32.65]:28952
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752191AbdKXOfj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Nov 2017 09:35:39 -0500
From: "Jorgen S. Hansen" <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
CC: "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Dexuan Cui <decui@microsoft.com>
Subject: Re: Remote Procedure Call (RPC) over AF_VSOCK draft 00
Date: Fri, 24 Nov 2017 14:35:36 +0000
Message-ID: <1CDDAC90-7309-43F1-8585-AAA632CAE07B@vmware.com>
References: <20171124105928.GA11868@stefanha-x1.localdomain>
In-Reply-To: <20171124105928.GA11868@stefanha-x1.localdomain>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 24, 2017, at 11:59 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote=
:
>=20
> The first draft of Remote Procedure Call (RPC) over AF_VSOCK is now
> available for review:
>=20
> Jorgen: I've summarized the current AF_VSOCK standardization status
> (i.e. there is no specification and implementors generally try to follow
> VMCI semantics for compatibility).  VMware vSockets is a superset of
> Linux AF_VSOCK because it has additional header files and APIs.  Is
> there an authoritative reference for plain AF_VSOCK that I'm not aware
> of?

No, unfortunately not. We only have the manual that you already provide a l=
ink to.

Thanks,
Jorgen=
