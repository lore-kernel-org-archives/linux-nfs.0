Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30061 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758636AbcIMPmm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2016 11:42:42 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=utf-8
Subject: audit of the use of SVC_DROP in server reply path
Date: Tue, 13 Sep 2016 11:42:37 -0400
Message-Id: <B5EAA4EA-81E3-4F57-9899-951F2A8180B3@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I think the two interesting cases are svc_set_client and svc_authorise.

Who does a "goto dropit;" inside svc_process_common?

	• svc_set_client returns SVC_DROP
		• When svcauth_gss_set_client calls svc_unix_set_client, which can return SVC_DROP
			• When svc_unix_set_client calls cache_check, and it returns -EAGAIN
			• When svc_unix_set_client calls unix_gid_find, and it returns -EAGAIN
		• svcauth_gss_accept
			• when gc_proc == RPC_GSS_PROC_DATA or RPC_GSS_PROC_DESTROY, and gss_check_seq_num fails
			• when gc_proc == RPC_GSS_PROC_DESTROY and the result length is larger than a page
	• pc_func returns rpc_drop_reply - only used by NLM
	• vs_dispatch returns 0
		• When nfsd_cache_lookup returns RC_DROPIT (the RPC is already in progress, or the client has retransmitted too soon): the server is going to reply anyway, safe to drop
		• pc_func returns nfserr_dropit (NFSv2's JUKEBOX)
		• RQ_DROPME is set (deferred requests?)
	• pc_encode is NULL - probably rare and inconsequential
	• svc_authorise returns non-zero
		• svcauth_gss_release returns a negative errno when integrity or privacy reply wrapping fails; i think this needs a connection reset
	• incoming RPC header is shorter than 24 bytes - connection reset would be better here anyway, IMO

The question I have is what does SVC_CLOSE mean for a UDP transport?


--
Chuck Lever



