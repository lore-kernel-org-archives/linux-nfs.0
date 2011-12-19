Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:54218 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab1LSWeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 17:34:10 -0500
Date: Mon, 19 Dec 2011 14:34:06 -0800
From: Jeremy Allison <jra@samba.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Jeremy Allison <jra@samba.org>, Ric Wheeler <ricwheeler@gmail.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
Message-ID: <20111219223406.GB20631@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <4EE8F75F.6070800@gmail.com>
 <20111214195931.GC10664@samba2>
 <4EEFB87F.9000104@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EEFB87F.9000104@zytor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2011 at 02:19:43PM -0800, H. Peter Anvin wrote:
> On 12/14/2011 11:59 AM, Jeremy Allison wrote:
> >>
> >> Can we resurrect this effort? Is copyfile() still a good way to go,
> >> or should we look at other hooks?
> > 
> > Windows uses a COPYCHUNK call, which specifies the
> > following parameters:
> > 
> > Definition of a copy "chunk":
> > 
> > hyper source_off;
> > hyper target_off;
> > uint32 length;
> > 
> > and an array of these chunks which is passed
> > into their kernel.
> > 
> > This is what we have to implement in Samba.
> > 
> 
> Could we do this by (re-)allowing sendfile() between two files?

Oooh - nice idea ! Yes, having a completely symmetric sendfile
which allows socket -> file, file -> socket, socket -> socket,
file -> file would be a great idea (IMHO).

Jeremy.
