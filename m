Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53701 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab0GNWHA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jul 2010 18:07:00 -0400
Subject: Re: remote I/O error nfs4err_resource
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christopher Weis <ccweis@gmail.com>
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTikoGWqS01RMgUpKNS3d6BIF7h7Lmo80Tm50XZpf@mail.gmail.com>
References: <AANLkTikoGWqS01RMgUpKNS3d6BIF7h7Lmo80Tm50XZpf@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Jul 2010 18:06:27 -0400
Message-ID: <1279145187.9967.58.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-14 at 16:14 -0500, Christopher Weis wrote:
> I just joined the list, so sorry for the lack of an inline response.
>  I appear to be running into the same issue recently discussed here...
> http://marc.info/?l=linux-nfsv4&m=127732700529997&w=2
> The thread was left with the following note: "The only solution to that problem, as far as I know, is to hunt down those clients which are keeping huge numbers of open files and/or locks, and possibly move them to a different server."
> In my case, there is only one client, and I'm dealing with a relatively low file count.  Read/write delegations are disabled within ONTAP, and something as simple as a "cp -r" or a "tar" of the local /usr filesystem to the NetApp volume using NFSv4 triggers the remote I/O error.  NFSv3 works fine.  Perhaps there is something else going on inside of ONTAP
> 
> So, my questions are:
> 1) Is this believed to be an ONTAP issue or a Linux issue (or both)?
> 2) Is Trond's recent patch set (http://thread.gmane.org/gmane.linux.nfs/33353) expected to fix the issue?
> 3) Are there known kernel bugzilla or NetApp BURTs to track the issue(s)?

OnTAP has a fixed size table of stateids: that is a known limitation,
but it is also a deliberate choice in order to ensure that the server
resources can be managed in a predictable manner.
OnTAP also has a bug which can affect you when you turn on delegations:
if the server runs out of free stateid table slots, then the natural
thing would be for it to start asking clients to return delegations.
This is not yet implemented in OnTAP and so Burt 388695 is tracking this
issue.

Current versions of Linux have an issue when you use file locking: they
can end up using a lot of stateids if you have one or several
applications does a lot of lock/unlock cycles but where the file stateid
never gets CLOSEd (which can happen if at least one application has the
file open at any point in time). That is a bug that the above patch set
aims to fix by adding client side support for the RELEASE_LOCKOWNER
operation.

Older versions of Linux also had a problem with delegation management:
instead of returning delegations for files that had seen no recent
activity, they would continue to hoard them until either the server
recalled them, or the entire inode dropped out of cache, or the
application performed some action that required the delegation return.
This has been fixed since Linux 2.6.29: we now return delegations that
have seen no activity in the last lease period.

Cheers
  Trond
