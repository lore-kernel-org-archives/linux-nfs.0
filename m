Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:52047 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103Ab1LNT7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 14:59:34 -0500
Date: Wed, 14 Dec 2011 11:59:31 -0800
From: Jeremy Allison <jra@samba.org>
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111214195931.GC10664@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <4EE8F75F.6070800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE8F75F.6070800@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:
> 
> Back at LinuxCon Prague, we talked about the new NFS and SCSI
> commands that let us offload copy operations to a storage device
> (like an NFS server or storage array).
> 
> This got new life in the virtual machine world where you might want
> to clone bulky guest files or ranges of blocks and was driven
> through the standards bodies by vmware, microsoft and some of the
> major storage vendors. Windows8 has this functionality fully coded
> and integrated in the GUI, I assume vmware also uses it and there
> are some vendors who announced support at the SNIA SDC conference.
> 
> We had an active thread a couple of years back that came out of the
> reflink work and, at the time, there seemed to be moderately
> positive support for adding a new system call that would fit this
> use case (Joel Becker's copyfile()).
> 
> Can we resurrect this effort? Is copyfile() still a good way to go,
> or should we look at other hooks?

Windows uses a COPYCHUNK call, which specifies the
following parameters:

Definition of a copy "chunk":

hyper source_off;
hyper target_off;
uint32 length;

and an array of these chunks which is passed
into their kernel.

This is what we have to implement in Samba.

Jeremy.
