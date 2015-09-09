Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:23061 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753338AbbIINhe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2015 09:37:34 -0400
From: Andrew W Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Subject: upgrade/downgrade race
Date: Wed, 09 Sep 2015 09:37:31 -0400
Message-ID: <m2h9n3btno.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


In attempting to troubleshoot other issues, we've run into this race
with 4.1.4 (both client and server) with a few cherry-picked patches
from upstream. This is my attempt at a redacted packet-capture.

These all affect the same fh/stateid:

116 -> OPEN (will be an upgrade / for write)
117 -> OPEN_DOWNGRADE (to read for the existing stateid / seqid = 0x6

121 -> OPEN_DOWNGRADE (completed last / seqid = 0x8)
122 -> OPEN (completed first / seqid = 0x7)

Attempts to write using that stateid fail because the stateid doesn't
have write access.

Any thoughts? I can share more data from the capture if needed.

==========

116     Sep  3, 2015 15:07:04.163242000 EDT     V4 Call SEQUENCE | PUTFH | OPEN DH: 0x8b975243/ | ACCESS FH: 0x8b975243, [Check: RD MD XT XE] | GETATTR FH: 0x8b975243
117     Sep  3, 2015 15:07:04.163289000 EDT     V4 Call SEQUENCE | PUTFH | OPEN_DOWNGRADE | GETATTR FH: 0x8b975243

...

121     Sep  3, 2015 15:07:04.163426000 EDT     V4 Reply (Call In 117) SEQUENCE | PUTFH | OPEN_DOWNGRADE | GETATTR
122     Sep  3, 2015 15:07:04.163443000 EDT     V4 Reply (Call In 116) SEQUENCE | PUTFH | OPEN StateID: 0x1f68 | ACCESS, [Allowed: RD MD XT XE] | GETATTR

...

155     Sep  3, 2015 15:07:04.165286000 EDT     V4 Call SEQUENCE | TEST_STATEID
156     Sep  3, 2015 15:07:04.165417000 EDT     V4 Reply (Call In 155) SEQUENCE | TEST_STATEID
157     Sep  3, 2015 15:07:04.165469000 EDT     V4 Call SEQUENCE | PUTFH | WRITE StateID: 0x072b Offset: 0 Len: 289 | GETATTR FH: 0x8b975243
158     Sep  3, 2015 15:07:04.165597000 EDT     V4 Reply (Call In 157) SEQUENCE | PUTFH | WRITE Status: NFS4ERR_OPENMODE
159     Sep  3, 2015 15:07:04.165713000 EDT     V4 Call SEQUENCE | TEST_STATEID
160     Sep  3, 2015 15:07:04.165839000 EDT     V4 Reply (Call In 159) SEQUENCE | TEST_STATEID
161     Sep  3, 2015 15:07:04.165913000 EDT     V4 Call SEQUENCE | PUTFH | WRITE StateID: 0x072b Offset: 0 Len: 289 | GETATTR FH: 0x8b975243
162     Sep  3, 2015 15:07:04.166040000 EDT     V4 Reply (Call In 161) SEQUENCE | PUTFH | WRITE Status: NFS4ERR_OPENMODE
163     Sep  3, 2015 15:07:04.166153000 EDT     V4 Call SEQUENCE | TEST_STATEID
164     Sep  3, 2015 15:07:04.166284000 EDT     V4 Reply (Call In 163) SEQUENCE | TEST_STATEID
165     Sep  3, 2015 15:07:04.166335000 EDT     V4 Call SEQUENCE | PUTFH | WRITE StateID: 0x072b Offset: 0 Len: 289 | GETATTR FH: 0x8b975243
166     Sep  3, 2015 15:07:04.166463000 EDT     V4 Reply (Call In 165) SEQUENCE | PUTFH | WRITE Status: NFS4ERR_OPENMODE

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
