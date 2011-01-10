Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smurfs.athenacr.com ([64.95.46.209]:36254 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751011Ab1AJUD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 15:03:26 -0500
Received: from atlanta.localnet (atlanta.em.in.athenacr.com [192.168.14.104])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTPS id 79FAE2BC76
	for <linux-nfs@vger.kernel.org>; Mon, 10 Jan 2011 14:55:30 -0500 (EST)
From: Roman Shtylman <shtylman@athenacr.com>
To: linux-nfs@vger.kernel.org
Subject: question about nfs4 with krb5 behavior
Date: Mon, 10 Jan 2011 14:55:30 -0500
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201101101455.30608.shtylman@athenacr.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have setup nfs4 with krb5 server and successfully mounted a client. Two 
people can log into the client box and both access their respective shares and 
not each other's. However, when one user (who lets say has root privs) uses 
root to become the second user (using su) then that user can now access the 
info of the user he became.

I was under the impression that this should not be possible as the tickets for 
access should still be tied to the first user they logged in as. Is this true? 
Or do I have an error in my setup?

Process:
Login as user A
(User B logs into the machine from another terminal)
sudo su B (to become user B on the machine)
<can now edit files which belong to B>

If User B does not login before user A becomes user B, user A is not able to 
edit user B's files even after he becomes user B.

Kernel version: 2.6.32-24

any clarification on behavior would be appreciated.

cheers,
~Roman
