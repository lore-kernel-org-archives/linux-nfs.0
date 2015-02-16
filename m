Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4247 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbbBPVhA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Feb 2015 16:37:00 -0500
Date: Mon, 16 Feb 2015 16:35:29 -0500
From: mdw@linuxbox.com
To: Joschi Brauchle <joschi.brauchle@tum.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Fehenberger, Tobias" <tobias.fehenberger@tum.de>,
        "Stinner, Markus" <markus.stinner@tum.de>,
        Tasnad Kernetzky <tasnad.kernetzky@tum.de>
Subject: Re: Question about NFS4 facls in combination with a GIT shared bare
 repo on NFSv4 share
Message-ID: <20150216213528.GA27453@soma.private.linuxbox.com>
References: <54E1F532.5030703@tum.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54E1F532.5030703@tum.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 16, 2015 at 02:48:34PM +0100, Joschi Brauchle wrote:
...
> Question 3:
> ==================
> Note that the problem is NOT solved with this ACL:
> ---------------
> /nfsv4/share # nfs4_getfacl repodir
> A:fdg:GROUP@:rwaDxtTnNcCoy
> ....
> /nfsv4/share # ls -l repodir
> drwxrwsr-x  7 myuser mygroup   4096 Feb 16 14:12 repodir/
> ---------------
...

I fancy I know something about nfsv4 acls, and I have to confess I can't
figure out what should be happening in your case, because you aren't
including enough detail for me to decide.  Which means I also can't
figure out where or what problem you're having, although I do agree
getting an error on "close" suggests something made a pretty wonky
decision.  I can't guarantee to be helpful in any case, but if you don't
get a better answer from somebody who knows more about your setup,
the following might help:
	
In order to figure out what "should" happen - complete acls, group membership, etc.
Your "...." could hide an awful lot of surprises.
You speak of "domains" - what sort are these and why do you think
they be considered the same as "@GROUP"?

Client & server identities and groups might map differently - is this the case here?

what is the fileserver running?   netapp?  solaris?  linux nfsd??  something else?

Presumably your client is linux - what version?  If from a distribution
which distro & package version?

Can you demonstrate your problem happen with dd or cp?  Or does it only
happen with git?

Are you using gssapi?  (better for tracing purposes if you can do this without.)
Can you record a network trace of the bad thing happening?  (this will
point whether it's a client or server side problem.)

Possibly helpful to know,:
	unix mode permissions work differently than an acl,
	with unix modes,
		owner permissions eclipse group permissions.
	with acls,
		group permissions add to owner permissions.
To accurately map unix mode bits into nfsv4 acls, you have to also
include 'deny' entries to keep groups from adding permissions the user
doen't have.

					-Marcus Watts
