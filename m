Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34562 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755999Ab0FQOrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:47:08 -0400
Message-ID: <4C1A3570.5030709@panasas.com>
Date: Thu, 17 Jun 2010 10:47:12 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/19]: merge pnfs client ops into nfs4's
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following patchset folds the pnfs client ops into their
nfs4 counterparts.

Note that the pnfs implementation forked off of old versions
of the nfs ops but we failed to update the pnfs implementation
when the original code they were derived from changed so the
current state captures an unintentional deviation.

Merging back the code ensures that the common paths are
correctly used and we deal only with the pnfs-specific
functionality.

This solves the bug where we were using two client structures when
mounting the server more than once and seeing the session destroyed
repeatedly (and the server returning 10052 on DESTROY_SESSION) and
eventually hitting the session recovery deadlock reported here:
http://marc.info/?l=linux-nfs&m=127663654927724&w=2

Here's the list of patches:
[PATCH 01/19] SQUASHME: pnfs-submit: merge pnfs4_proc_setattr into nfs4_proc_setattr
[PATCH 02/19] SQUASHME: pnfs4_read_done status variable is unused
[PATCH 03/19] SQUASHME: pnfs-submit: optionally pass nfs_client to nfs4_async_handle_error
[PATCH 04/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 1
[PATCH 05/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 2
[PATCH 06/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into nfs4_read_done - part 3
[PATCH 07/19] SQUASHME: pnfs-submit: get rid of pnfs4_read_done
[PATCH 08/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 1
[PATCH 09/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 2
[PATCH 10/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 3
[PATCH 11/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into nfs4_write_done - part 4
[PATCH 12/19] SQUASHME: pnfs-submit: get rid of pnfs4_write_done
[PATCH 13/19] SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 1
[PATCH 14/19] SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 2
[PATCH 15/19] SQUASHME: pnfs-submit: merge pnfs4_commit_done into nfs4_commit_done - part 3
[PATCH 16/19] SQUASHME: pnfs-submit: get rid of pnfs4_commit_done
[PATCH 17/19] SQUASHME: pnfs-submit: merge pnfs4_proc_write_setup into nfs4_proc_write_setup
[PATCH 18/19] SQUASHME: pnfs-submit: merge pnfs4_proc_commit_setup into nfs4_proc_commit_setup
[PATCH 19/19] SQUASHME: pnfs-submit: get rid of pnfs_v4_clientops
