From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: 2.6.30 approaching
Date: Wed, 18 Mar 2009 19:41:41 -0400
Message-ID: <20090318234141.GQ18894@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59787 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbZCRXlm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 19:41:42 -0400
Received: from bfields by pickle.fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1Lk5OH-0005uy-If
	for linux-nfs@vger.kernel.org; Wed, 18 Mar 2009 19:41:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following list isn't complete yet, but it's what I have queued up
for 2.6.30 so far.  I'm assuming the merge window will be open pretty
soon.

I'm in the unusual position of thinking that my incoming patch queue is
empty at the moment.  Which means: if you sent me something recently and
haven't gotten a response back, then I've lost it, and I'd be grateful
if you could resend.

--b.

Alexandros Batsakis (1):
      nfsd: lock state around put client and delegation in nfsd4_cb_recall

Benny Halevy (1):
      NFSD: return nfsv4 error code nfserr_notsupp rather than nfsv[23]'s nfserr_opnotsupp

Chuck Lever (1):
      SUNRPC: Clean up static inline functions in svc_xprt.h

David Shaw (1):
      Short write in nfsd becomes a full write to the client

Greg Banks (3):
      knfsd: remove the nfsd thread busy histogram
      knfsd: avoid overloading the CPU scheduler with enormous load averages
      knfsd: add file to export stats about nfsd pools

Harvey Harrison (1):
      nfs: replace uses of __constant_{endian}

J. Bruce Fields (25):
      nfsd4: split lockstateid/openstateid release logic
      nfsd4: remove a forward declaration
      nfsd4: split open/lockowner release code
      nfsd: clarify exclusive create bitmask result.
      nfsd4: fix misplaced comment
      nfsd4: use helper for copying filehandles for replay
      nfsd4: use helper for copying delegation filehandle
      nfsd4: trivial preprocess_stateid_op cleanup
      nfsd4: move check_stateid_generation check
      nfsd4: remove redundant "if" in nfs4_preprocess_stateid_op
      nfsd4: remove unneeded local variable
      nfsd4: remove some dprintk's
      nfsd4: add a helper function to decide if stateid is delegation
      nfsd4: separate delegreturn case from preprocess_stateid_op
      nfsd4: fail when delegreturn gets a non-delegation stateid
      nfsd4: remove unused CHECK_FH flag
      nfsd4: rename io_during_grace_disallowed
      nfsd4: put_nfs4_client does not require state lock
      nfsd4: remove use of mutex for file_hashtable
      nfsd4: fix do_probe_callback errors
      nfsd4: move rpc_client setup to a separate function
      nfsd4: support putpubfh operation
      nfsd4: don't do lookup within readdir in recovery code
      nfsd4: remove redundant check from nfsd4_open
      nfsd4: don't check ip address in setclientid

Manish Katiyar (1):
      nfsd : Define NFSD only when FILE_LOCKING is enabled

Miklos Szeredi (1):
      lockd: clean up blocking lock cases of nlsmvc_lock()

Olga Kornievskaia (1):
      svcrpc: take advantage of tcp autotuning

Qinghuang Feng (1):
      NFSD: cleanup for nfs3proc.c

Sachin S. Prabhu (1):
      Inconsistent setattr behaviour

wengang wang (1):
      nfsd(v2/v3): fix the failure of creation from HPUX client

