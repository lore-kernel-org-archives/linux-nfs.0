Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63124 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab1LNUaR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2011 15:30:17 -0500
Message-ID: <4EE90753.6060700@gmail.com>
Date: Wed, 14 Dec 2011 15:30:11 -0500
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
To: Jeremy Allison <jra@samba.org>
CC: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
References: <4EE8F75F.6070800@gmail.com> <20111214195931.GC10664@samba2>
In-Reply-To: <20111214195931.GC10664@samba2>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/14/2011 02:59 PM, Jeremy Allison wrote:
> On Wed, Dec 14, 2011 at 02:22:07PM -0500, Ric Wheeler wrote:
>> Back at LinuxCon Prague, we talked about the new NFS and SCSI
>> commands that let us offload copy operations to a storage device
>> (like an NFS server or storage array).
>>
>> This got new life in the virtual machine world where you might want
>> to clone bulky guest files or ranges of blocks and was driven
>> through the standards bodies by vmware, microsoft and some of the
>> major storage vendors. Windows8 has this functionality fully coded
>> and integrated in the GUI, I assume vmware also uses it and there
>> are some vendors who announced support at the SNIA SDC conference.
>>
>> We had an active thread a couple of years back that came out of the
>> reflink work and, at the time, there seemed to be moderately
>> positive support for adding a new system call that would fit this
>> use case (Joel Becker's copyfile()).
>>
>> Can we resurrect this effort? Is copyfile() still a good way to go,
>> or should we look at other hooks?
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
> Jeremy.

This is a public pointer to the draft NFS proposal:

http://tools.ietf.org/id/draft-lentini-nfsv4-server-side-copy-06.txt

The T10 site has some click through that I was not too happy about agreeing to. 
NetApp (Fred Knight) had some nice presentations that he presented about how 
SCSI does this in two different ways...

Ric



