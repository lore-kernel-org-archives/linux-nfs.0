Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:48650 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159Ab1LSWUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 17:20:44 -0500
Message-ID: <4EEFB87F.9000104@zytor.com>
Date: Mon, 19 Dec 2011 14:19:43 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Jeremy Allison <jra@samba.org>
CC: Ric Wheeler <ricwheeler@gmail.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
References: <4EE8F75F.6070800@gmail.com> <20111214195931.GC10664@samba2>
In-Reply-To: <20111214195931.GC10664@samba2>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/14/2011 11:59 AM, Jeremy Allison wrote:
>>
>> Can we resurrect this effort? Is copyfile() still a good way to go,
>> or should we look at other hooks?
> 
> Windows uses a COPYCHUNK call, which specifies the
> following parameters:
> 
> Definition of a copy "chunk":
> 
> hyper source_off;
> hyper target_off;
> uint32 length;
> 
> and an array of these chunks which is passed
> into their kernel.
> 
> This is what we have to implement in Samba.
> 

Could we do this by (re-)allowing sendfile() between two files?

	-hpa

