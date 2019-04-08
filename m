Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9813EC10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:27:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7305D20879
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:27:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726895AbfDHQ1S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 12:27:18 -0400
Received: from fieldses.org ([173.255.197.46]:36322 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726415AbfDHQ1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 12:27:18 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 0EE87893; Mon,  8 Apr 2019 12:27:18 -0400 (EDT)
Date:   Mon, 8 Apr 2019 12:27:18 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     =?utf-8?B?5piT5p6X?= <yilin@iie.ac.cn>
Cc:     linux-nfs@vger.kernel.org, jlayton@kernel.org,
        jian liu <liujian6@iie.ac.cn>,
        "csong@cs.ucr.edu" <csong@cs.ucr.edu>,
        "yiqiuping@gmail.com" <yiqiuping@gmail.com>,
        "zhiyunq@cs.ucr.edu" <zhiyunq@cs.ucr.edu>
Subject: Re: should the svc_xprt_get =?utf-8?Q?call?=
 =?utf-8?Q?ed_after_the_object_assigned_to_a_global_variable=EF=BC=9F?=
Message-ID: <20190408162718.GB13787@fieldses.org>
References: <4ac222da.7767b.169f799c48f.Coremail.yilin@iie.ac.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4ac222da.7767b.169f799c48f.Coremail.yilin@iie.ac.cn>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Apr 07, 2019 at 07:40:43PM +0800, 易林 wrote:
> Hi, all:
>     when analyzing the v5.1 source code, I notice that in function nfsd4_process_cb_update, 
> the object c->cn_xprt assigned to a local variable conn.cb_xprt with a refcount increased:
>       if (c) {
> 		svc_xprt_get(c->cn_xprt);
> 		conn.cb_xprt = c->cn_xprt;
> 		ses = c->cn_session;
> 	}
> 
> and the variable conn.cb_xprt will be assigned to a global object clp->cl_cb_conn.cb_xprt 
> in callee setup_callback_client with a condition that clp->cl_minorversion != 0:
> 
>        if (clp->cl_minorversion == 0) {
> 		if (!clp->cl_cred.cr_principal &&
> 				(clp->cl_cred.cr_flavor >= RPC_AUTH_GSS_KRB5))
> 			return -EINVAL;
> 		args.client_name = clp->cl_cred.cr_principal;
> 		args.prognumber	= conn->cb_prog;
> 		args.protocol = XPRT_TRANSPORT_TCP;
> 		args.authflavor = clp->cl_cred.cr_flavor;
> 		clp->cl_cb_ident = conn->cb_ident;
> 	} else {
> 		if (!conn->cb_xprt)
> 			return -EINVAL;
> 		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
> 		clp->cl_cb_session = ses;
> 		args.bc_xprt = conn->cb_xprt;
> 		args.prognumber = clp->cl_cb_session->se_cb_prog;
> 		args.protocol = conn->cb_xprt->xpt_class->xcl_ident |
> 				XPRT_TRANSPORT_BC;
> 		args.authflavor = ses->se_cb_sec.flavor;
> 	}
> 
> what if the cl_minorversion equals 0 ? the c->cn_xprt's refcount will increased without a assignment. 
> Can it be ensured that the cl_minorversion won't be zero with the refcount increment?

Sessions were introduced with NFSv4.1, __nfsd4_find_backchannel should
always find clp->cl_sessions empty in the 4.0 case.

So I think it's OK.  Not the clearest code ever, though.  I wonder if it
would make sense to separate the 4.0 and 4.1 codepaths earlier on, given
how little code they share.

--b.
