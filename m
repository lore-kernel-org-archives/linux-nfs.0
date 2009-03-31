From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 0/9] nfs41 for 2.6.30 session reset fix and cleanup
Date: Tue, 31 Mar 2009 22:01:03 +0300
Message-ID: <49D2686F.6040604@panasas.com>
References: <> <1238455599-12151-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23748 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753471AbZCaTBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 15:01:10 -0400
In-Reply-To: <1238455599-12151-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've merged these and the cleaned up patchset you
sent for nfs41-for-2.6.30 (with minor edits to 
commit messages and one checkpatch fix to
#define nfs4_call_sync.

This is now available on
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-for-2.6.30

Benny

On Mar. 31, 2009, 2:26 +0300, andros@netapp.com wrote:
> This patch series applies to nfs41-for-2.6.30.
> 
> These patches clean up nfs41_sequence_done
> 0001-SQUASHME-nfs41-remove-unused-error-checking-in-nfs.patch
> 0002-SQUASHME-nfs41-remove-nfs4_has_session-check-in-nfs.patch
> 0003-SQUASHME-nfs41-remove-nfs_client-pointer-check.patch
> 
> These patches clean up session reset errors
> 0004-SQUASHME-nfs41-_nfs4_async_handle_error-fix-sessio.patch
> 0005-SQUASHME-nfs41-nfs4_handle_exception-fix-session-re.patch
> 0006-SQUASHME-nfs41-remove-switch-on-error-from-nfs41_s.patch
> 
> This patch fixes session reset which was failing repeated runs of the
> pynfs testclient SESSIONRESET2 test.
> 0007-SQUASHME-nfs41-resset-the-session-from-nfs41_setup.patch
> 
> These patches add session reset handeling to the state recovery code.
> 0008-nfs41-session-reset-in-nfs4_recovery_handle_error.patch
> 0009-nfs41-reset-session-on-nfs4_do_reclaim-session-rese.patch
> 
> 
> Tests:
> With CONFIG_NFS_V4_1 set:
> Connectathon passes with v4 and v4.1 mounts.
> Connectathon basic passes against pynfs server that resets the session every
> 50th sequenence operation.
> python testclient REBOOT1 REBOOT2 SESSIONRESET1 pass. SESSIONRESET2 passes
> with multiple tests (which was failing prior to patch 0007)
> 
> With CONFIG_NFS_V4_1 not set:
> Connectathon passes.
> 
> 
> -->Andy
> 
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
