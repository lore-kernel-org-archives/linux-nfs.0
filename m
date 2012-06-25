Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:28352 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217Ab2FYUnU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 16:43:20 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: rpcauth_create() returns ERR_PTR
Date: Mon, 25 Jun 2012 16:43:13 -0400
Message-Id: <17B0469E-0417-4F74-A035-625D41E5609B@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

nfs4_create_sec_client() and nfs4_lookup_root_sec() both invoke rpcauth_create().  They check to see that it returned something that wasn't NULL.

As far as I can tell, rpcauth_create() reports an error by returning something that IS_ERR.  It doesn't return NULL.  nfs_init_server_rpcclient() appears to be correct.

The fix looks simple, but since I don't have any unit tests for this area of code, I was hoping you could take it from here.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




