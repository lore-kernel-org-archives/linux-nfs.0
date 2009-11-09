From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: 2.6.31 under "heavy" NFS load.
Date: Mon, 09 Nov 2009 20:30:44 +0100
Message-ID: <4AF86DE4.5010607@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:47537 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbZKITiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2009 14:38:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi List.

When a lot (~60 all on 1GbitE) of NFS clients are hitting an NFS server
that has an 10GbitE NIC sitting on it I'm seeing high IO-wait load
(>50%) and load number over 100 on the server. This is a change since
2.6.29 where the IO-wait load under similar workload was less than 10%.

The system has 16 Opteron cores.

All data the NFS-clients are reading are "memory recident" since they
are all reading off the same 10GB of data and the server has 32GB of
main memory dedicated to nothing else than serving NFS.

A snapshot of top looks like this:
http://krogh.cc/~jesper/top-hest-2.6.31.txt

The load is generally alot higher than on 2.6.29 and it "explodes" to
over 100 when a few processes begin utillizing the disk while serving
files over NFS. "dstat" reports a read-out of 10-20MB/s from disk which
is close to what I'd expect. and the system delivers around 600-800MB/s
over the NIC in this workload.


Sorry that I cannot be more specific, I can answer questions on a
running 2.6.31 kernel, but I cannot reboot the system back to 2.6.29
just to test since the system is "in production". I tried 2.6.30 and it
has the same pattern as 2.6.31, so based on that fragile evidence the
change should be found in between 2.6.29 and 2.6.30. I hope a "wague"
report is better than none.

-- 
Jesper
