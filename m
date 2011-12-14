Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46551 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755459Ab1LNTWN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 14:22:13 -0500
Message-ID: <4EE8F75F.6070800@gmail.com>
Date: Wed, 14 Dec 2011 14:22:07 -0500
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
To: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: copy offload support in Linux - new system call needed?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Back at LinuxCon Prague, we talked about the new NFS and SCSI commands that let 
us offload copy operations to a storage device (like an NFS server or storage 
array).

This got new life in the virtual machine world where you might want to clone 
bulky guest files or ranges of blocks and was driven through the standards 
bodies by vmware, microsoft and some of the major storage vendors. Windows8 has 
this functionality fully coded and integrated in the GUI, I assume vmware also 
uses it and there are some vendors who announced support at the SNIA SDC conference.

We had an active thread a couple of years back that came out of the reflink work 
and, at the time, there seemed to be moderately positive support for adding a 
new system call that would fit this use case (Joel Becker's copyfile()).

Can we resurrect this effort? Is copyfile() still a good way to go, or should we 
look at other hooks?

Thanks!

Ric



