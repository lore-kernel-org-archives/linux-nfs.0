Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37244 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756477Ab3EJATM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 20:19:12 -0400
References: <518C2104.7060107@RedHat.com>
In-Reply-To: <518C2104.7060107@RedHat.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <7B0E9027-8F04-491D-9320-E74E54D0EF19@oracle.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RPC: AUTH_GSS upcall timed out.
Date: Thu, 9 May 2013 20:20:09 -0400
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On May 9, 2013, at 6:19 PM, Steve Dickson <SteveD@redhat.com> wrote:

> Hello,
> 
> commit 4edaa308888b4bd629fa025cc6d5b2bf1a2a51db
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Sat Mar 16 15:56:20 2013 -0400
> 
>    NFS: Use "krb5i" to establish NFSv4 state whenever possible
> 
> Introduced a hard code call to nfs_create_rpc_client(RPC_AUTH_GSS_KRB5I)
> in nfs4_init_client() which means if rpc.gssd is not running the mount 
> hangs for a bit logs the "RPC: AUTH_GSS upcall timed out" and then tries 
> nfs_create_rpc_client(RPC_AUTH_NULL) allowing the mount to succeed.
> 
> Is this a known "feature"? 

Read the archives, we've been working on a fix for the past few days.

This commit fixes a regression, so it would be just as hard to revert as to fix the upcall.



> 
> steved.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
