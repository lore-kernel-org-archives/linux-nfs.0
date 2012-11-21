Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:46604 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab2KUQJR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Nov 2012 11:09:17 -0500
Received: by mail-qc0-f174.google.com with SMTP id o22so4879745qcr.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Nov 2012 08:09:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPihpKANv22e=LwfkSgDX8EcRJgmzT4haBd5COpusyio0_wCJA@mail.gmail.com>
References: <CAPihpKD4cPDUfxFtP-ZPjEfEnUo_Ps6s_AEAxT29m=SmhFfuiw@mail.gmail.com>
 <CABpMAyJk2uDeYvY5z-qCOt+9DYwKYs5dXOD4aQN6eggypK5c2Q@mail.gmail.com> <CAPihpKANv22e=LwfkSgDX8EcRJgmzT4haBd5COpusyio0_wCJA@mail.gmail.com>
From: Idan Kedar <idank@tonian.com>
Date: Wed, 21 Nov 2012 18:08:36 +0200
Message-ID: <CABpMAyKa8UAxFu8sRrkvf=HqfdLLpURPC3LLsyOLoEdqArdk0A@mail.gmail.com>
Subject: Re: Metadata Server for PNFS testing
To: Rodel Miguel <rodelfmiguel@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 21, 2012 at 5:29 PM, Rodel Miguel <rodelfmiguel@gmail.com> wrote:
> Hi Idan,
>
> It would be nice to have a simple file layout, but any layout would
> do.  Thank you very much!
>
> Kind Regards,
> Rodel
>

The pNFS metadata server is available in Benny Halevy's git
repository. Look here for instructions:

http://linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions

For file layout, you can compile the kernel with pnfs-lexp, which
exports a local file system with pNFS file layout.

I generally prefer to use object layout, because it allows me to
physically separate the MDS from the data server. in order to set up
object layout, compile the MDS with the exofs file system, and use it
as your pNFS export. exofs requires an OSD rather than a plain block
device, so look up for instructions on how to set this up.

as for the client, the upstream client works, though if you want to
use object layout you'll need scsi-initiator-utils.

-- 
idank
