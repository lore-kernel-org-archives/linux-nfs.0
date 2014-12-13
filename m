Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33259 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964843AbaLMDpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 22:45:25 -0500
Date: Fri, 12 Dec 2014 22:45:19 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: William Andros Adamson <andros@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC add rpc_gss_svc_t to gssd upcall
Message-ID: <20141213034518.GA28337@fieldses.org>
References: <1418423580-1212-1-git-send-email-andros@netapp.com>
 <CAHQdGtQkrjWV61qPCN=vbo9zy1CKxu0Fp00vvpWV57tWWJ9FhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQkrjWV61qPCN=vbo9zy1CKxu0Fp00vvpWV57tWWJ9FhA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 12, 2014 at 07:26:39PM -0500, Trond Myklebust wrote:
> Hi Andy
> 
> On Fri, Dec 12, 2014 at 5:33 PM,  <andros@netapp.com> wrote:
> > From: Andy Adamson <andros@netapp.com>
> >
> > Otherwise rpc.gssd will send a V4 NULL RPCSEC_GSS_INIT call with an RPCSEC_GSS
> > service of rpc_gss_svc_none for rpc_sec_gss_svc_integrity/privacy requests
> > from the kernel.
> 
> I thought this behaviour of using rpc_gss_svc_none for the RPCSEC_GSS
> negotiation in userland and then "stepping up" to a stricter service
> in the kernel had been declared legal by the powers that be.

Yes, in fact:

	https://www.ietf.org/rfc/rfc2203.txt 5.2.2:

	In a creation request, the seq_num and service fields are
	undefined and both must be ignored by the server.

--b.
