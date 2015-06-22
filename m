Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:32874 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbbFVC3d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Jun 2015 22:29:33 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 7E0AAAAB2
	for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2015 02:29:32 +0000 (UTC)
Date: Mon, 22 Jun 2015 12:29:06 +1000
From: NeilBrown <neilb@suse.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFSv4 state management issue - Linux disagrees with Netapp.
Message-ID: <20150622122906.03f253b6@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


hi,
 I've been trying to understand some NFS state management errors seen
 on a recent (4.0) Linux kernel talking to a recent (I think) Netapp
 filer.  I managed to get a tcpdump trace that shows that is happening
 quite nicely.
 It is fairly clear the the Linux client doesn't not handle the
 behaviour of the Netapp well.  My main question is whether the Netapp
 behaviour is out-of-spec?  If so, Linux should be fixed.  If not,
 Linux maybe should be alert for this behaviour.

 There is only one file that is important.  It is REMOVEd immediately
 before the following sequence - so we are sure neither client nor
 server thinks it exists.

 1/ Client request open/writeonly/create/exclusive
 2/ server grants with no delegation
 3/ client writes to file
 4/ client performs a LOOKUP, then OPEN, readonly
 5/ server grants the open and provides a read-only delegation
 6/ client uses OPEN_DOWNGRADE to give up read access - now writeonly
    again
 7/ server grants
 8/ application tries to create hardlink, so client tries to
    pro-actively return the delegation.
    Specifically requests an OPEN writeonly CLAIM_DELEGATE_CUR
 9/ server denies - this causes an error message on client
10/ client sends LINK request to server
11/ server calls back asking for the delegation to be returned.
12/ client sends DELEGRTURN - server accepts
13/ server confirms that LINK has completed.


I have reports which suggest that the state management thread starts
spinning at this point, but I haven't been able to confirm that or get
details yet.


Step 5 is the questionable step. Should the netapp provide a read-only
delegation when the client has a active write-only open?  It seems
a little odd, but I cannot see that it is clearly wrong.

Currently this leads to the client having an open stateid which is
read/write and a delegation stateid which is read-only.
When it returns the read-only open with OPEN_DOWNGRADE it has an
open stateid which is writeonly and a delegation stateid which is
read-only.

struct nfs4_state isn't able to record this distinction.  It seems to
assume that the open stateid and the delegation stateid will have the
same access pattern.  So when asked to return the delegation it assumes
that the wronly open it has is associated with that delegation and so
tries to return it.

I'm guessing that 'struct nfs4_state' should get another 'fmode_t'
which records the mode of 'stateid' (while the current "fmode_t state"
refers only to open_stateid, and delegation->type refers only to
delegation->stateid).  I'll see what that does to the code, but I
thought I'd ask first and describe the big picture in case I'm missing
some important details of the protocol.

Thanks,
NeilBrown

 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
