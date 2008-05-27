From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [NFS] Corrupted stateid
Date: Tue, 27 May 2008 13:33:45 -0700
Message-ID: <1211920425.3907.26.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54597 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755695AbYE0U4p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2008 16:56:45 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K16Dp-000631-Lq
	for linux-nfs@vger.kernel.org; Wed, 28 May 2008 06:56:42 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm helping debug a problem where a Linux client (2.6.18 kernel) is
talking to an AIX server. We see an issue where Linux is happily using
the stateid issued by the server (other part only, does not include the
sequence number):

47B2DD610000014100128042

and then occasionally uses a different stateid:

47B2DD610000014100148042

This stateid is the correct stateid + 20000, however, AIX accepted it
(very odd).

Interestingly, this alternate stateid is used in a close, which the AIX
server also accepts, returning the following stateid:

47B2DD610000014100140042

which is the original stateid +20000 - 8000

It appears that somewhere the code is overlaying some flag bits onto the
stateid.

The weird part is that way before this, AIX suddenly complains about the
original stateid with 
NFS4ERR_BAD_STATEID. The sequence number has not changed at all during
this period.

Apparently another trace does show the Linux client making this same
corruption of the stateid, but in that case, the AIX server DOES
complain.

Any thoughts what might be going on here from a Linux perspective?

Thanks

Frank





-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

